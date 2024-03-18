CREATE TABLE public.users (
    id               INTEGER IDENTITY(1,1) PRIMARY KEY,
    user_id          VARCHAR(50) NOT NULL,
    user_attributes  SUPER,
    user_created     TIMESTAMP DEFAULT SYSDATE
);

CREATE TABLE public.events (   
    id                INTEGER IDENTITY(1,1) PRIMARY KEY,
    event_id          VARCHAR(50) NOT NULL,
    event_name        VARCHAR(255),
    user_id           VARCHAR(50) REFERENCES Users(id),
    event_attributes  SUPER, -- Use SUPER data type for JSON
    event_created     TIMESTAMP DEFAULT SYSDATE
);
