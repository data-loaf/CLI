CREATE TABLE public.events (
  id INTEGER identity(1, 1),
  name VARCHAR(100) NOT NULL,
  time DATETIME DEFAULT SYSDATE
);