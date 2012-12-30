using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Runtime.Serialization.Json;
using System.IO;
using System.Text;
using System.Data;
using System.Data.SqlClient;

public partial class ajax : System.Web.UI.Page
{
    private string connectionString = "Data Source=ANTONIO-PC\\SQLSERVER;Initial Catalog=worldoflove;Integrated Security=True";

    protected void Page_Load(object sender, EventArgs e)
    {
        Response.Expires = -1;
        //required to keep the page from being cached on the client's browser

        Response.ContentType = "text/plain";
        Response.Write(getXml());

        Response.End();
    }

    public static string Serialize<T>(T obj)
    {
        DataContractJsonSerializer serializer = new DataContractJsonSerializer(obj.GetType());
        using (MemoryStream ms = new MemoryStream())
        {
            serializer.WriteObject(ms, obj);
            return Encoding.Default.GetString(ms.ToArray());
        }
    }

    public static T Deserialise<T>(string json)
    {
        T obj = Activator.CreateInstance<T>();
        using (MemoryStream ms = new MemoryStream(Encoding.Unicode.GetBytes(json)))
        {
            DataContractJsonSerializer serializer = new DataContractJsonSerializer(obj.GetType());
            obj = (T)serializer.ReadObject(ms); // <== Your missing line
            return obj;
        }
    }

    public string getXml()
    {
        return sql("SELECT * FROM person").GetXml();
    }

    public DataSet sql(string sql)
    {
        using (SqlConnection connection = new SqlConnection(connectionString))
        {
            using (SqlDataAdapter da = new SqlDataAdapter(sql, connection))
            {
                try
                {
                    connection.Open();
                    DataSet ds = new DataSet();
                    da.Fill(ds);
                    return ds;
                }
                catch (Exception)
                {
                    return new DataSet();
                }
                finally
                {
                    connection.Close();
                }
            }
        }
    }

    public bool sqlexecute(string sql)
    {
        using (SqlConnection connection = new SqlConnection(connectionString))
        {
            using (SqlCommand da = new SqlCommand(sql, connection))
            {
                try
                {
                    connection.Open();
                    da.ExecuteNonQuery();
                    return true;
                }
                catch (Exception)
                {
                    return false;
                }
                finally
                {
                    connection.Close();
                }
            }
        }
    }

    public object sqlinsert(string sql)
    {
        using (SqlConnection connection = new SqlConnection(connectionString))
        {
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                try
                {
                    connection.Open();
                    return command.ExecuteScalar();
                }
                catch (Exception)
                {
                    return 0;
                }
                finally
                {
                    connection.Close();
                }
            }
        }
    }
}