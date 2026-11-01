using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web;

namespace WebAppPoliMusicV2.DAL
{
    /// <summary>
    /// Data access layer for the table [TBL_SONG] of BDD_PoliMusic.
    /// Contains the CRUD operations plus the play counter update.
    /// </summary>
    public class Song
    {
        private const string SelectSentence =
            "SELECT [ID_SONG], [SONG_NAME], [SONG_PATH], ISNULL([PLAYS], 0) AS [PLAYS] FROM [TBL_SONG]";

        private string strConnectionString;

        public Song(string strConnString)
        {
            strConnectionString = strConnString;
        }

        /// <summary>
        /// INSERT a new song. Returns the number of affected rows.
        /// </summary>
        public int Save(Entities.Song song)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "INSERT INTO [TBL_SONG] ([SONG_NAME], [SONG_PATH], [PLAYS]) " +
                        "VALUES (@SONG_NAME, @SONG_PATH, @PLAYS)";
                    cmd.Parameters.AddWithValue("@SONG_NAME", song.SongName);
                    cmd.Parameters.AddWithValue("@SONG_PATH", song.SongPath);
                    cmd.Parameters.AddWithValue("@PLAYS", song.Plays);
                    cmd.Connection = con;
                    con.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// SELECT all the songs, ordered by name.
        /// </summary>
        public DataTable Read()
        {
            DataTable dtSong = new DataTable();
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand(SelectSentence + " ORDER BY [SONG_NAME]", con))
                {
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        sda.Fill(dtSong);
                        return dtSong;
                    }
                }
            }
        }

        /// <summary>
        /// SELECT all the songs as a list of entities (used by the presentation layer).
        /// </summary>
        public List<Entities.Song> GetAll()
        {
            List<Entities.Song> songs = new List<Entities.Song>();
            DataTable dtSong = Read();
            foreach (DataRow row in dtSong.Rows)
            {
                songs.Add(MapSong(row));
            }
            return songs;
        }

        /// <summary>
        /// SELECT one song by its identifier. Returns null when it does not exist.
        /// </summary>
        public Entities.Song GetById(int idSong)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand(SelectSentence + " WHERE [ID_SONG] = @ID_SONG", con))
                {
                    cmd.Parameters.AddWithValue("@ID_SONG", idSong);
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader(CommandBehavior.SingleRow))
                    {
                        if (reader.Read())
                        {
                            return MapSong(reader);
                        }
                    }
                }
            }
            return null;
        }

        /// <summary>
        /// UPDATE the name, the path and the plays of an existing song.
        /// </summary>
        public int Update(Entities.Song song)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "UPDATE [TBL_SONG] SET " +
                        "[SONG_NAME] = @SONG_NAME " +
                        ", [SONG_PATH] = @SONG_PATH " +
                        ", [PLAYS] = @PLAYS " +
                        "WHERE [ID_SONG] = @ID_SONG";
                    cmd.Parameters.AddWithValue("@ID_SONG", song.ID);
                    cmd.Parameters.AddWithValue("@SONG_NAME", song.SongName);
                    cmd.Parameters.AddWithValue("@SONG_PATH", song.SongPath);
                    cmd.Parameters.AddWithValue("@PLAYS", song.Plays);
                    cmd.Connection = con;
                    con.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// DELETE a song by its identifier.
        /// </summary>
        public int Delete(int idSong)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "DELETE FROM [TBL_SONG] WHERE [ID_SONG] = @ID_SONG";
                    cmd.Parameters.AddWithValue("@ID_SONG", idSong);
                    cmd.Connection = con;
                    con.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// Adds one reproduction to the song and returns the new counter value.
        /// </summary>
        public int IncreasePlays(int idSong)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                con.Open();
                using (SqlCommand cmd = new SqlCommand(
                    "UPDATE [TBL_SONG] SET [PLAYS] = ISNULL([PLAYS], 0) + 1 WHERE [ID_SONG] = @ID_SONG", con))
                {
                    cmd.Parameters.AddWithValue("@ID_SONG", idSong);
                    cmd.ExecuteNonQuery();
                }
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT ISNULL([PLAYS], 0) FROM [TBL_SONG] WHERE [ID_SONG] = @ID_SONG", con))
                {
                    cmd.Parameters.AddWithValue("@ID_SONG", idSong);
                    object returnValue = cmd.ExecuteScalar();
                    return returnValue == null ? 0 : Convert.ToInt32(returnValue);
                }
            }
        }

        /// <summary>
        /// Sum of the plays column, used by the summary cards of the page.
        /// </summary>
        public int GetTotalPlays()
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand("SELECT ISNULL(SUM([PLAYS]), 0) FROM [TBL_SONG]", con))
                {
                    con.Open();
                    object returnValue = cmd.ExecuteScalar();
                    return returnValue == null ? 0 : Convert.ToInt32(returnValue);
                }
            }
        }

        /// <summary>
        /// Returns the ID_SONG of the song that already uses that path, or 0 when the path is free.
        /// </summary>
        public int CheckExistSongPath(string songPath)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand("SELECT [ID_SONG] FROM [TBL_SONG] WHERE [SONG_PATH] = @SONG_PATH", con))
                {
                    cmd.Parameters.AddWithValue("@SONG_PATH", songPath);
                    con.Open();
                    object returnValue = cmd.ExecuteScalar();
                    return returnValue == null ? 0 : Convert.ToInt32(returnValue);
                }
            }
        }

        private static Entities.Song MapSong(DataRow row)
        {
            Entities.Song song = new Entities.Song();
            song.ID = Convert.ToInt32(row["ID_SONG"]);
            song.SongName = Convert.ToString(row["SONG_NAME"]);
            song.SongPath = Convert.ToString(row["SONG_PATH"]);
            song.Plays = row["PLAYS"] == DBNull.Value ? 0 : Convert.ToInt32(row["PLAYS"]);
            return song;
        }

        private static Entities.Song MapSong(SqlDataReader reader)
        {
            Entities.Song song = new Entities.Song();
            song.ID = Convert.ToInt32(reader["ID_SONG"]);
            song.SongName = Convert.ToString(reader["SONG_NAME"]);
            song.SongPath = Convert.ToString(reader["SONG_PATH"]);
            song.Plays = reader["PLAYS"] == DBNull.Value ? 0 : Convert.ToInt32(reader["PLAYS"]);
            return song;
        }
    }

}
