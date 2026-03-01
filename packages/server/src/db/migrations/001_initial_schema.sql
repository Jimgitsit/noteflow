-- =============================================================================
-- NoteFlow — Migration 001: Initial Schema
-- =============================================================================

-- Enable pgcrypto for gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- -----------------------------------------------------------------------------
-- users
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  email         TEXT        NOT NULL UNIQUE,
  password_hash TEXT        NOT NULL,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- notes
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS notes (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title      TEXT        NOT NULL DEFAULT '',
  body       TEXT        NOT NULL DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Full-text search index on title + body
CREATE INDEX IF NOT EXISTS notes_fts_idx
  ON notes USING GIN (to_tsvector('english', title || ' ' || body));

-- Index for listing notes by user, sorted by updated_at
CREATE INDEX IF NOT EXISTS notes_user_updated_idx
  ON notes(user_id, updated_at DESC);

-- -----------------------------------------------------------------------------
-- tags
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tags (
  id      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name    TEXT NOT NULL,
  UNIQUE (user_id, name)
);

-- -----------------------------------------------------------------------------
-- note_tags  (many-to-many join table)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS note_tags (
  note_id UUID NOT NULL REFERENCES notes(id) ON DELETE CASCADE,
  tag_id  UUID NOT NULL REFERENCES tags(id)  ON DELETE CASCADE,
  PRIMARY KEY (note_id, tag_id)
);

-- -----------------------------------------------------------------------------
-- Auto-update updated_at on notes
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS notes_updated_at ON notes;
CREATE TRIGGER notes_updated_at
  BEFORE UPDATE ON notes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
