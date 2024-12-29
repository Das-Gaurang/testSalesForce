public class JSON2Apex {

	public String result;
	public List<MessageTemplates> messageTemplates;
    public class ConInfo {
        public String fieldNameOrPath;
        public String value;          
    }

	public class MessageTemplates {
		public String id;
		public String elementName;
	}

	public List<Records> records;

	public class Records {
		public List<Columns_Z> columns;
	}

	public class Columns_Z {
		public String fieldNameOrPath;
		public String value;
	}
    
	
	public static JSON2Apex parse(String json) {
		return (JSON2Apex) System.JSON.deserialize(json, JSON2Apex.class);
	}
}