import redis

r = redis.Redis(host='cache-72fd3b.redis.cache.windows.net', port=6380, db=0, password='QSvVrCuv4M3f3EYsJ5HRI7ehmrLgQKrwxAzCaKcGZ5A=', ssl=True)

pipe = r.pipeline()
pipe.set('foo', 5)
pipe.set('bar', 18.5)
pipe.set('blee', "hello world!")
pipe.execute()
print(r.get("blee"))

r.mset({"Croatia": "Zagreb", "Bahamas": "Nassau"})
print(r.get("Bahamas"))

