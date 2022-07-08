package board;

import java.sql.Date;

import lombok.Data;


@Data
public class BoardVO {
	private int id, readcnt, no;
	private String title, content, writer, name, filename, filepath;
	private Date writedate;
	
}