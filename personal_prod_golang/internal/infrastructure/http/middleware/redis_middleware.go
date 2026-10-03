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

// CacheKey builds a per-user cache key. The user id has to be part of the key:
// keying on the request path alone serves one user's goals to every other user,
// because /getGoal is a single shared path.
func CacheKey(userId string, path string) string {
	return "cache:" + userId + ":" + path
}

func RedisCacheMiddleWare(rdb *redis.Client, duration time.Duration) gin.HandlerFunc {
	return func(c *gin.Context) {
		// Runs after AuthMiddleWare so user_id is populated. Without it there is
		// no safe key, so let the request through uncached.
		userId := c.GetString("user_id")
		if userId == "" {
			c.Next()
			return
		}
		cacheKey := CacheKey(userId, c.Request.URL.Path)

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
