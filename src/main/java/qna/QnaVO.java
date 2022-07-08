package qna;

import java.sql.Date;

import lombok.Data;

@Data
public class QnaVO {
	private int id, readcnt, no, root, step, indent;
	private String title, content, writer, filename, filepath, name;
	private Date writedate;
	
}