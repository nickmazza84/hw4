-- schema


CREATE TABLE Artist (
    artist_id INT AUTO_INCREMENT PRIMARY KEY,
    artist_name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE Album (
    album_id INT AUTO_INCREMENT PRIMARY KEY,
    album_name VARCHAR(255) NOT NULL,
    artist_id INT NOT NULL,
    release_date DATE NOT NULL,
    UNIQUE (album_name, artist_id),
    FOREIGN KEY (artist_id) REFERENCES Artist(artist_id)
);

CREATE TABLE Song (
    song_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    artist_id INT NOT NULL,
    album_id INT,
    release_date DATE NOT NULL,
    UNIQUE (title, artist_id),
    FOREIGN KEY (artist_id) REFERENCES Artist(artist_id),
    FOREIGN KEY (album_id) REFERENCES Album(album_id)
);

CREATE TABLE Genre (
    genre_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE SongGenre (
    song_id INT NOT NULL,
    genre_id INT NOT NULL,
    PRIMARY KEY (song_id, genre_id),
    FOREIGN KEY (song_id) REFERENCES Song(song_id),
    FOREIGN KEY (genre_id) REFERENCES Genre(genre_id)
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
    UNIQUE (user_id, title),
    FOREIGN KEY (user_id) REFERENCES User(user_id)
);

CREATE TABLE PlaylistSong (
    playlist_id INT NOT NULL,
    song_id INT NOT NULL,
    PRIMARY KEY (playlist_id, song_id),
    FOREIGN KEY (playlist_id) REFERENCES Playlist(playlist_id),
    FOREIGN KEY (song_id) REFERENCES Song(song_id)
);

CREATE TABLE Rating (
    rating_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    rating_value TINYINT NOT NULL CHECK (rating_value BETWEEN 1 AND 5),
    rating_date DATE NOT NULL,
    song_id INT,
    album_id INT,
    playlist_id INT,
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    FOREIGN KEY (song_id) REFERENCES Song(song_id),
    FOREIGN KEY (album_id) REFERENCES Album(album_id),
    FOREIGN KEY (playlist_id) REFERENCES Playlist(playlist_id)
);

-- queuries

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

SELECT 
    a.album_name AS album_name,
    ROUND(AVG(r.rating_value), 2) AS average_user_rating
FROM Rating r, Album a
WHERE r.album_id = a.album_id
  AND r.rating_date BETWEEN '1990-01-01' AND '1999-12-31'
  AND r.album_id IS NOT NULL
GROUP BY a.album_id, a.album_name
ORDER BY average_user_rating DESC, a.album_name ASC
LIMIT 10;

SELECT 
    g.name AS genre_name,
    COUNT(*) AS number_of_song_ratings
FROM Rating r, Song s, Genre g, SongGenre sg
WHERE r.song_id = s.song_id
  AND s.song_id = sg.song_id
  AND sg.genre_id = g.genre_id
  AND r.rating_date BETWEEN '1991-01-01' AND '1995-12-31'
  AND r.song_id IS NOT NULL
GROUP BY g.genre_id, g.name
ORDER BY number_of_song_ratings DESC
LIMIT 3;


SELECT 
    u.username,
    p.title AS playlist_title,
    ROUND(AVG(sr.avg_rating), 2) AS average_song_rating
FROM Playlist p, User u, PlaylistSong ps, (
    SELECT 
        r.song_id,
        AVG(r.rating_value) AS avg_rating
    FROM Rating r
    WHERE r.song_id IS NOT NULL
    GROUP BY r.song_id
) sr
WHERE p.user_id = u.user_id
  AND p.playlist_id = ps.playlist_id
  AND ps.song_id = sr.song_id
GROUP BY u.username, p.title
HAVING average_song_rating >= 4.0;

SELECT 
    u.username,
    COUNT(*) AS number_of_ratings
FROM Rating r, User u
WHERE r.user_id = u.user_id
  AND (r.song_id IS NOT NULL OR r.album_id IS NOT NULL)
GROUP BY u.user_id, u.username
ORDER BY number_of_ratings DESC
LIMIT 5;

SELECT 
    a.artist_name,
    COUNT(s.song_id) AS number_of_songs
FROM Song s
JOIN Artist a ON s.artist_id = a.artist_id
WHERE s.release_date BETWEEN '1990-01-01' AND '2010-12-31'
GROUP BY a.artist_id, a.artist_name
ORDER BY number_of_songs DESC
LIMIT 10;

SELECT 
    s.title AS song_title,
    COUNT(ps.playlist_id) AS number_of_playlists
FROM PlaylistSong ps
JOIN Song s ON ps.song_id = s.song_id
GROUP BY s.song_id, s.title
ORDER BY number_of_playlists DESC, s.title ASC
LIMIT 10;

SELECT 
    s.title AS song_title,
    a.artist_name,
    COUNT(r.rating_id) AS number_of_ratings
FROM Rating r
JOIN Song s ON r.song_id = s.song_id
JOIN Artist a ON s.artist_id = a.artist_id
WHERE s.album_id IS NULL
GROUP BY s.song_id, s.title, a.artist_name
ORDER BY number_of_ratings DESC
LIMIT 20;

SELECT 
    a.artist_name
FROM Artist a
JOIN Song s ON a.artist_id = s.artist_id
GROUP BY a.artist_id, a.artist_name
HAVING MAX(s.release_date) <= '1993-12-31';
