using System;
using System.Configuration;
using System.Globalization;
using System.Web;
using System.Web.SessionState;

namespace WebAppPoliMusicV2.Handlers
{
    /// <summary>
    /// Generic handler that adds one reproduction to a song without reloading Song.aspx.
    /// Usage: Handlers/PlayCounter.ashx?id=5
    /// Response: {"id":5,"plays":12} or {"id":5,"plays":-1} when something fails.
    /// </summary>
    public class PlayCounter : IHttpHandler, IRequiresSessionState
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            context.Response.Cache.SetCacheability(HttpCacheability.NoCache);

            int idSong;
            if (!int.TryParse(context.Request.QueryString["id"], out idSong) || idSong <= 0)
            {
                context.Response.StatusCode = 400;
                context.Response.Write("{\"id\":0,\"plays\":-1}");
                return;
            }

            if (context.Session != null && context.Session[Util.Constants.USER] == null)
            {
                context.Response.StatusCode = 401;
                context.Response.Write("{\"id\":" + idSong.ToString(CultureInfo.InvariantCulture) + ",\"plays\":-1}");
                return;
            }

            try
            {
                string strConnString = ConfigurationManager.ConnectionStrings["BDD_PoliMusicConnectionString"].ConnectionString;
                int plays = new BLL.Song(strConnString).RegisterPlay(idSong);
                context.Response.Write("{\"id\":" + idSong.ToString(CultureInfo.InvariantCulture) +
                    ",\"plays\":" + plays.ToString(CultureInfo.InvariantCulture) + "}");
            }
            catch (Exception)
            {
                context.Response.StatusCode = 500;
                context.Response.Write("{\"id\":" + idSong.ToString(CultureInfo.InvariantCulture) + ",\"plays\":-1}");
            }
        }

        public bool IsReusable
        {
            get { return false; }
        }
    }
}
