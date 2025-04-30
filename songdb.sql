CREATE TABLE Artist (
    artist_id INT AUTO_INCREMENT PRIMARY KEY,
    artist_name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE Album (
    album_id INT AUTO_INCREMENT PRIMARY KEY,
    album_name VARCHAR(255) NOT NULL,
    artist_id INT NOT NULL,
    release_date DATE NOT NULL,
    UNIQUE (album_name, artist_id)
);

CREATE TABLE Song (
    song_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    artist_id INT NOT NULL,
    album_id INT NULL,
    release_date DATE NOT NULL,
    UNIQUE (title, artist_id)
);

CREATE TABLE Genre (
    genre_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE SongGenre (
    song_id INT NOT NULL,
    genre_id INT NOT NULL,
    PRIMARY KEY (song_id, genre_id)
);

CREATE TABLE User (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Playlist (
    playlist_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    created_at DATETIME NOT NULL,
    UNIQUE (user_id, title)
);

CREATE TABLE PlaylistSong (
    playlist_id INT NOT NULL,
    song_id INT NOT NULL,
    PRIMARY KEY (playlist_id, song_id)
);

CREATE TABLE Rating (
    rating_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    rating_value TINYINT NOT NULL CHECK (rating_value BETWEEN 1 AND 5),
    rating_date DATE NOT NULL,
    song_id INT NULL,
    album_id INT NULL,
    playlist_id INT NULL
);


SELECT genre.name AS genre, COUNT(*) AS number_of_songs 
FROM songgenre, genre 
WHERE songgenre.genre_id = genre.genre_id 
GROUP BY genre.name
ORDER BY number_of_songs DESC
LIMIT 3;

SELECT DISTINCT artist.artist_name AS artist_name 
FROM artist, song 
WHERE artist.artist_id = song.artist_id
GROUP BY artist.artist_name
HAVING COUNT(DISTINCT CASE WHEN song.album_id IS NULL THEN song.song_id END) > 0
   AND COUNT(DISTINCT CASE WHEN song.album_id IS NOT NULL THEN song.song_id END) > 0;