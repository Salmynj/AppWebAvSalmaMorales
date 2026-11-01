using System;
using System.Collections.Generic;
using System.Data;
using System.Web;

namespace WebAppPoliMusicV2.BLL
{
    /// <summary>
    /// Business layer: validates the song data and delegates the persistence to the DAL.
    /// </summary>
    public class Song
    {
        private const int MaxSongNameLength = 50;   // [SONG_NAME] varchar(50)
        private const int MaxSongPathLength = 255;  // [SONG_PATH] varchar(255)

        private string strConnectionString;

        public Song(string strConnString)
        {
            strConnectionString = strConnString;
        }

        public int Save(Entities.Song song)
        {
            return new DAL.Song(strConnectionString).Save(song);
        }

        public DataTable Read()
        {
            return new DAL.Song(strConnectionString).Read();
        }

        public List<Entities.Song> GetAll()
        {
            return new DAL.Song(strConnectionString).GetAll();
        }

        public Entities.Song GetById(int idSong)
        {
            return new DAL.Song(strConnectionString).GetById(idSong);
        }

        public int Update(Entities.Song song)
        {
            return new DAL.Song(strConnectionString).Update(song);
        }

        public int Delete(int idSong)
        {
            return new DAL.Song(strConnectionString).Delete(idSong);
        }

        public int RegisterPlay(int idSong)
        {
            return new DAL.Song(strConnectionString).IncreasePlays(idSong);
        }

        public int GetTotalPlays()
        {
            return new DAL.Song(strConnectionString).GetTotalPlays();
        }

        public int CheckExistSongPath(string songPath)
        {
            return new DAL.Song(strConnectionString).CheckExistSongPath(songPath);
        }

        /// <summary>
        /// Validates the required fields before a Save or an Update.
        /// Returns an empty string when everything is fine.
        /// </summary>
        public string ValidateSong(Entities.Song song)
        {
            if (song == null)
            {
                return "The song information is required!";
            }
            if (string.IsNullOrEmpty(song.SongName) || song.SongName.Trim() == string.Empty)
            {
                return "Song name is required!";
            }
            if (song.SongName.Trim().Length > MaxSongNameLength)
            {
                return "Song name must have " + MaxSongNameLength + " characters at most!";
            }
            if (string.IsNullOrEmpty(song.SongPath) || song.SongPath.Trim() == string.Empty)
            {
                return "Song path is required!";
            }
            if (song.SongPath.Trim().Length > MaxSongPathLength)
            {
                return "Song path must have " + MaxSongPathLength + " characters at most!";
            }
            if (song.Plays < 0)
            {
                return "The plays counter can not be negative!";
            }
            return string.Empty;
        }

        /// <summary>
        /// Validates that the audio path is not used by another song of the table.
        /// </summary>
        public string ValidateDuplicated(Entities.Song song)
        {
            int idSong = CheckExistSongPath(song.SongPath.Trim());
            if (idSong != 0 && idSong != song.ID)
            {
                return "There is already a song registered with that path!";
            }
            return string.Empty;
        }
    }

}
