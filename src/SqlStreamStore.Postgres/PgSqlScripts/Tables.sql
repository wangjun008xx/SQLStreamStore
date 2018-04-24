CREATE SEQUENCE IF NOT EXISTS __schema__.streams_seq
  START 1;

CREATE TABLE IF NOT EXISTS __schema__.streams (
  id          CHAR(42)      NOT NULL,
  id_original VARCHAR(1000) NOT NULL,
  id_internal INT           NOT NULL DEFAULT nextval('__schema__.streams_seq'),
  version     INT           NOT NULL DEFAULT (-1),
  position    BIGINT        NOT NULL DEFAULT (-1),
  max_age     INT           NULL,
  max_count   INT           NULL,
  CONSTRAINT pk_streams PRIMARY KEY (id_internal)
);

COMMENT ON SCHEMA __schema__ IS '{ "version": 1 }';

ALTER SEQUENCE __schema__.streams_seq
OWNED BY __schema__.streams.id_internal;

CREATE UNIQUE INDEX IF NOT EXISTS streams_by_id
  ON __schema__.streams (id);

CREATE SEQUENCE IF NOT EXISTS __schema__.messages_seq
  START 0
  MINVALUE 0;

CREATE TABLE IF NOT EXISTS __schema__.messages (
  stream_id_internal INT          NOT NULL,
  stream_version     INT          NOT NULL,
  "position"         BIGINT       NOT NULL DEFAULT nextval('__schema__.messages_seq'),
  message_id         UUID         NOT NULL,
  created_utc        TIMESTAMP    NOT NULL,
  type               VARCHAR(128) NOT NULL,
  json_data          VARCHAR      NOT NULL,
  json_metadata      VARCHAR,
  CONSTRAINT pk_messages PRIMARY KEY (position),
  CONSTRAINT fk_messages_stream FOREIGN KEY (stream_id_internal) REFERENCES __schema__.streams (id_internal)
);

ALTER SEQUENCE __schema__.messages_seq
OWNED BY __schema__.messages.position;

CREATE UNIQUE INDEX IF NOT EXISTS messages_by_position
  ON __schema__.messages (position);

CREATE UNIQUE INDEX IF NOT EXISTS messages_by_stream_id_internal_and_message_id
  ON __schema__.messages (stream_id_internal, message_id);

CREATE UNIQUE INDEX IF NOT EXISTS messages_by_stream_id_internal_and_stream_version
  ON __schema__.messages (stream_id_internal, stream_version);

CREATE INDEX IF NOT EXISTS messages_by_stream_id_internal_and_created_utc
  ON __schema__.messages (stream_id_internal, created_utc);

CREATE TABLE IF NOT EXISTS __schema__.deleted_streams (
  id CHAR(42) NOT NULL,
  CONSTRAINT pk_deleted_streams PRIMARY KEY (id)
);

DO $F$
BEGIN
  CREATE TYPE __schema__.new_stream_message AS (
    message_id    UUID,
    "type"        VARCHAR(128),
    json_data     VARCHAR,
    json_metadata VARCHAR
  );
  EXCEPTION
  WHEN duplicate_object
    THEN null;
END $F$;