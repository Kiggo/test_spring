package board;

import lombok.Data;

@Data
public class BoardCommentVO {
	private int id, pid;
	private String writer, name, content;
	private String writedate;
}