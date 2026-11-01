using System;
using System.Collections.Generic;
using System.Configuration;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WebAppPoliMusicV2
{
    public partial class Song : System.Web.UI.Page
    {
        private const string ConnectionStringName = "BDD_PoliMusicConnectionString";
        private const string DefaultUserPhoto = "~/UserImages/default.jpg";

        protected void Page_Load(object sender, EventArgs e)
        {
            Entities.User user = GetAuthenticatedUser();
            if (user == null)
            {
                Response.Redirect("~/Login.aspx", true);
                return;
            }

            ShowAuthenticatedUser(user);

            if (!Page.IsPostBack)
            {
                BindSongList();
            }
        }

        /// <summary>
        /// Reads the user stored in the session when the login was successful.
        /// If the session expired but the authentication cookie is still valid,
        /// the user name of the cookie is used to keep the page working.
        /// </summary>
        private Entities.User GetAuthenticatedUser()
        {
            if (Session[Util.Constants.USER] != null)
            {
                return (Entities.User)Session[Util.Constants.USER];
            }
            if (User.Identity != null && User.Identity.IsAuthenticated)
            {
                Entities.User userFromCookie = new Entities.User();
                userFromCookie.UserName = User.Identity.Name;
                userFromCookie.UserType = Util.Constants.ID_USER_NORMAL;
                return userFromCookie;
            }
            return null;
        }

        /// <summary>
        /// Shows the name, the role and the photo of the authenticated user.
        /// </summary>
        private void ShowAuthenticatedUser(Entities.User user)
        {
            string userName = string.IsNullOrEmpty(user.UserName) ? "user" : user.UserName.Trim();

            lblUserName.Text = Server.HtmlEncode(userName);
            lblWelcomeName.Text = Server.HtmlEncode(userName);
            lblUserRole.Text = user.UserType == Util.Constants.ID_USER_ADMIN ? "ADMIN" : "USER";
            lblUserEmail.Text = Server.HtmlEncode(string.IsNullOrEmpty(user.Email) ? "active session" : user.Email);

            imgUserPhoto.ImageUrl = GetUserPhotoUrl(user.Photo);
            imgUserPhoto.AlternateText = "Photo of " + userName;
        }

        /// <summary>
        /// Loads the songs from the database through the BLL and binds the repeater.
        /// </summary>
        private void BindSongList()
        {
            try
            {
                BLL.Song bllSong = new BLL.Song(GetConnectionString());
                List<Entities.Song> songs = bllSong.GetAll();

                rptSongs.DataSource = songs;
                rptSongs.DataBind();

                rptSongs.Visible = songs.Count > 0;
                pnlEmpty.Visible = songs.Count == 0;

                lblTotalSongs.Text = songs.Count.ToString();
                lblChipCount.Text = songs.Count.ToString();
                lblTotalPlays.Text = bllSong.GetTotalPlays().ToString("N0");
            }
            catch (Exception ex)
            {
                rptSongs.Visible = false;
                pnlEmpty.Visible = false;
                lblTotalSongs.Text = "0";
                lblChipCount.Text = "0";
                lblTotalPlays.Text = "0";
                ShowMessage("The song list could not be loaded: " + ex.Message, false);
            }
        }

        private void ShowMessage(string message, bool success)
        {
            lblMessage.Visible = true;
            lblMessage.Text = Server.HtmlEncode(message);
            lblMessage.CssClass = success ? "alert alert-ok" : "alert alert-error";
        }

        private string GetConnectionString()
        {
            ConnectionStringSettings settings = ConfigurationManager.ConnectionStrings[ConnectionStringName];
            if (settings == null || string.IsNullOrEmpty(settings.ConnectionString))
            {
                throw new ConfigurationErrorsException(
                    "The connection string '" + ConnectionStringName + "' was not found in Web.config.");
            }
            return settings.ConnectionString;
        }

        private string GetUserPhotoUrl(string photo)
        {
            if (string.IsNullOrEmpty(photo) || photo.Trim() == string.Empty)
            {
                return ResolveUrl(DefaultUserPhoto);
            }
            return ResolveUrl(photo.Trim());
        }

        /// <summary>
        /// Converts the path stored in [SONG_PATH] (for example ~/songFiles/x.mp3)
        /// into a URL that the browser can request.
        /// </summary>
        protected string GetSongUrl(object songPath)
        {
            string path = Convert.ToString(songPath);
            if (string.IsNullOrEmpty(path))
            {
                return string.Empty;
            }

            path = path.Replace('\\', '/').Trim();

            if (path.StartsWith("~/"))
            {
                return ResolveUrl(path);
            }
            if (path.StartsWith("/"))
            {
                return path;
            }
            if (path.StartsWith("../"))
            {
                return path;
            }
            return ResolveUrl("~/" + path);
        }

        /// <summary>
        /// First letter of the song name, used by the small cover of each row.
        /// </summary>
        protected string GetInitial(object songName)
        {
            string name = Convert.ToString(songName);
            if (string.IsNullOrEmpty(name) || name.Trim() == string.Empty)
            {
                return "?";
            }
            return Server.HtmlEncode(name.Trim().Substring(0, 1).ToUpper());
        }

        /// <summary>
        /// Formats the [PLAYS] column with thousands separator.
        /// </summary>
        protected string FormatPlays(object plays)
        {
            int value;
            if (!int.TryParse(Convert.ToString(plays), out value))
            {
                value = 0;
            }
            return value.ToString("N0");
        }
    }
}
