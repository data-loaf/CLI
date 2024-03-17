CREATE TABLE public.events (
    id                INTEGER IDENTITY(1,1) PRIMARY KEY,
    event_id          VARCHAR(50) NOT NULL,
    event_name        VARCHAR(255),
    user_id           INTEGER REFERENCES Users(id),
    event_created     DATETIME DEFAULT SYSDATE,
    event_attributes  SUPER -- Use SUPER data type for JSON
);

CREATE TABLE public.users (
    id               INTEGER IDENTITY(1,1) PRIMARY KEY,
    user_id          VARCHAR(50) NOT NULL,
    user_created     DATETIME DEFAULT SYSDATE,
    user_attributes  SUPER 
);
