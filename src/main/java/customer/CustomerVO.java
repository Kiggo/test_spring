package customer;

import lombok.Data;

@Data
public class CustomerVO {
	private int id, no;
	private String name, gender, email, phone;

}