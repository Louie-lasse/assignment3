
import java.sql.*; // JDBC stuff.
import java.util.Properties;

public class PortalConnection {

    // Set this to e.g. "portal" if you have created a database named portal
    // Leave it blank to use the default database of your database user
    static final String DBNAME = "portal";
    // For connecting to the portal database on your local machine
    static final String DATABASE = "jdbc:postgresql://localhost/"+DBNAME;
    static final String USERNAME = "postgres";
    static final String PASSWORD = Password.getPassword();

    // For connecting to the chalmers database server (from inside chalmers)
    // static final String DATABASE = "jdbc:postgresql://brage.ita.chalmers.se/";
    // static final String USERNAME = "tda357_nnn";
    // static final String PASSWORD = "yourPasswordGoesHere";


    // This is the JDBC connection object you will be using in your methods.
    private Connection conn;

    public PortalConnection() throws SQLException, ClassNotFoundException {
        this(DATABASE, USERNAME, PASSWORD);  
    }

    // Initializes the connection, no need to change anything here
    public PortalConnection(String db, String user, String pwd) throws SQLException, ClassNotFoundException {
        Class.forName("org.postgresql.Driver");
        Properties props = new Properties();
        props.setProperty("user", user);
        props.setProperty("password", pwd);
        conn = DriverManager.getConnection(db, props);
    }


    // Register a student on a course, returns a tiny JSON document (as a String)
    public String register(String student, String courseCode) {
        try(PreparedStatement st =conn.prepareStatement(
                "INSERT INTO Registrations VALUES (?,?);"
        )){
            st.setString(1, student);
            st.setString(2,courseCode);
            st.executeUpdate();
            return "{\"success\":true\"}";

        } catch (SQLException e){
            return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
        }
    }

    // Unregister a student from a course, returns a tiny JSON document (as a String)
    public String unregister(String student, String courseCode){
        try(PreparedStatement st = conn.prepareStatement(
                "DELETE FROM Registrations WHERE student=? AND course=?;"
        )){
            st.setString(1,student);
            st.setString(2,courseCode);
            st.executeUpdate();
            return "{\"success\":true\"}";
        } catch (SQLException e){
            return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
        }
    }

    // Return a JSON document containing lots of information about a student, it should validate against the schema found in information_schema.json
    public String getInfo(String student) throws SQLException{
        
        try(PreparedStatement st = conn.prepareStatement(
            // replace this with something more useful
            "SELECT idnr,name,login,program,branch,array_agg(json_build_object('course',T.course,'grade',grade)) finnished, " +
                    "array_agg(R.course) registered, " +
                    "seminarcourses,mathcredits,researchcredits,totalCredits,qualified AS canGraguate " +
                "FROM BasicInformation B" +
                "JOIN PathToGraduation P ON B.idnr=P.student" +
                "FULL OUTER JOIN Taken T ON P.student=T.student" +
                "FULL OUTER JOIN Registrations R ON R.student = B.idnr " +
                "GROUP BY (idnr,name,login,program,branch,seminarcourses,mathcredits,researchcredits,totalCredits,canGraguate) "
            )){
            
            st.setString(1, student);

            ResultSet rs = st.executeQuery();

            if(rs.next()) {
                return rs.getString("jsondata");
            }
            else
              return "{\"student\":\"does not exist :(\"}";

        } 
    }

    // This is a hack to turn an SQLException into a JSON string error message. No need to change.
    public static String getError(SQLException e){
       String message = e.getMessage();
       int ix = message.indexOf('\n');
       if (ix > 0) message = message.substring(0, ix);
       message = message.replace("\"","\\\"");
       return message;
    }
}