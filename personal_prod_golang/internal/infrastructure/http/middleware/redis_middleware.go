package middleware

import (
	"bytes"
	"log"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/redis/go-redis/v9"
)

// RedisCacheMiddleWare accepts the redis client as a parameter
type responseBodyWriter struct {
	gin.ResponseWriter
	body *bytes.Buffer
}

func (w *responseBodyWriter) Write(b []byte) (int, error) {
	w.body.Write(b)
	return w.ResponseWriter.Write(b)
}

func RedisCacheMiddleWare(rdb *redis.Client, duration time.Duration) gin.HandlerFunc {
	return func(c *gin.Context) {
		// Consider using a more specific key to avoid collisions
		cacheKey := "goal:" + c.Request.URL.RequestURI()

		// 1. Try to fetch from Redis
		val, err := rdb.Get(c.Request.Context(), cacheKey).Result()
		if err == nil {
			// Success: return cached data and stop
			log.Printf("Cache HIT for key: %s", cacheKey)
			c.Header("X-Cache", "HIT")
			c.Data(http.StatusOK, "application/json", []byte(val))
			c.Abort()
			return
		}

		// 2. Cache Miss: Record the response
		log.Printf("Cache MISS for key: %s", cacheKey)
		c.Header("X-Cache", "MISS")
		
		writer := &responseBodyWriter{
			body:           &bytes.Buffer{},
			ResponseWriter: c.Writer,
		}
		c.Writer = writer

		c.Next()

		// 3. Store in Redis if the request was successful
		if writer.Status() == http.StatusOK && writer.body.Len() > 0 {
			err := rdb.Set(c.Request.Context(), cacheKey, writer.body.String(), duration).Err()
			if err != nil {
				log.Printf("Failed to cache response: %v", err)
			} else {
				log.Printf("Cached response for key: %s with TTL: %v", cacheKey, duration)
			}
		}
	}
}