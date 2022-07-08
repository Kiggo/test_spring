package notice;

import java.sql.Date;

import lombok.Data;

@Data
public class NoticeVO {
	private int id, readcnt, no, root, step, indent;

	private String title, content, writer, filename, filepath, name;
	
	private Date writedate;
}
