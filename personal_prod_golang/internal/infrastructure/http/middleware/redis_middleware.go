package middleware

import (
	"bytes"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/redis/go-redis/v9"
)

// RedisCacheMiddleWare accepts the redis client as a parameter
func RedisCacheMiddleWare(rdb *redis.Client, duration time.Duration) gin.HandlerFunc {
	return func(c *gin.Context) {
		// We use the full URI (including query params) as the key
		cacheKey := c.Request.URL.RequestURI()

		// 1. Try to fetch from Redis
		val, err := rdb.Get(c, cacheKey).Result()
		if err == nil {
			// Success: return cached data and stop
			c.Header("X-Cache", "HIT")
			c.Data(http.StatusOK, "application/json", []byte(val))
			c.Abort()
			return
		}

		// 2. Cache Miss: Record the response
		c.Header("X-Cache", "MISS")
		writer := &responseBodyWriter{body: &bytes.Buffer{}, ResponseWriter: c.Writer}
		c.Writer = writer

		c.Next()

		// 3. Store in Redis if the request was successful
		if c.Writer.Status() == http.StatusOK {
			rdb.Set(c, cacheKey, writer.body.String(), duration)
		}
	}
}

// Helper to capture the response body
type responseBodyWriter struct {
	gin.ResponseWriter
	body *bytes.Buffer
}

func (w *responseBodyWriter) Write(b []byte) (int, error) {
	w.body.Write(b)
	return w.ResponseWriter.Write(b)
}