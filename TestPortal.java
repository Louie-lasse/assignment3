public class TestPortal {

   // enable this to make pretty printing a bit more compact
   private static final boolean COMPACT_OBJECTS = false;

   // This class creates a portal connection and runs a few operation

   public static void main(String[] args) {
      try{

         PortalConnection c = new PortalConnection();

         String s1 = "1111111111";
         String s2 = "2222222222";
         String s4 = "4444444444";
         String s6 = "6666666666";

         //1
         System.out.println(c.getInfo(s2));

         pause();

         //2
         System.out.println(c.register(s2, "CCC444"));
         System.out.println(c.getInfo(s2));

         pause();
         //3
         System.out.println(c.register(s2, "CCC444")); //error

         pause();
         //4
         System.out.println(c.unregister(s2, "CCC444")); //SELECT * FROM Registrations WHERE student = '2222222222'
         pause();
         System.out.println(c.unregister(s2, "CCC444")); //error

         pause();
         //5
         System.out.println(c.register(s6, "CCC111")); //error

         pause();
         //6
         System.out.println(c.unregister(s4, "CCC333"));
         System.out.println(c.register(s4, "CCC333")); //SELECT * FROM CourseQueuePositions WHERE course = 'CCC333'
        
         pause();
         //7
         //SELECT * FROM CourseQueuePositions WHERE course = 'CCC333'
         System.out.println(c.unregister(s4, "CCC333")); //SELECT * FROM CourseQueuePositions WHERE course = 'CCC333'
         pause();
         System.out.println(c.register(s4, "CCC333")); //SELECT * FROM CourseQueuePositions WHERE course = 'CCC333'

         pause();
         //8
         System.out.println(c.unregister(s1, "CCC777")); //SELECT * FROM Registrations WHERE course = 'CCC777'

         pause();
         //9
         System.out.println(c.unregister(s1, "CCC333'; DELETE FROM Registrations WHERE student=student;--")); //SELECT * FROM Registrations
         pause();



      
      } catch (ClassNotFoundException e) {
         System.err.println("ERROR!\nYou do not have the Postgres JDBC driver (e.g. postgresql-42.2.18.jar) in your runtime classpath!");
      } catch (Exception e) {
         e.printStackTrace();
      }
   }
   
   
   
   public static void pause() throws Exception{
     System.out.println("PRESS ENTER");
     while(System.in.read() != '\n');
   }
   
   // This is a truly horrible and bug-riddled hack for printing JSON. 
   // It is used only to avoid relying on additional libraries.
   // If you are a s2ent, please avert your eyes.
   public static void prettyPrint(String json){
      System.out.print("Raw JSON:");
      System.out.println(json);
      System.out.println("Pretty-printed (possibly broken):");
      
      int indent = 0;
      json = json.replaceAll("\\r?\\n", " ");
      json = json.replaceAll(" +", " "); // This might change JSON string values :(
      json = json.replaceAll(" *, *", ","); // So can this
      
      for(char c : json.toCharArray()){
        if (c == '}' || c == ']') {
          indent -= 2;
          breakline(indent); // This will break string values with } and ]
        }
        
        System.out.print(c);
        
        if (c == '[' || c == '{') {
          indent += 2;
          breakline(indent);
        } else if (c == ',' && !COMPACT_OBJECTS) 
           breakline(indent);
      }
      
      System.out.println();
   }
   
   public static void breakline(int indent){
     System.out.println();
     for(int i = 0; i < indent; i++)
       System.out.print(" ");
   }   
}