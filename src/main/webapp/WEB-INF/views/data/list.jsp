
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>data list jsp</title>
<style type="text/css">
#map {
	position: absolute;
	width: 800px;
	height: 600px;
	left: 50%;
	top: 50%;
	transform: translate(-50%, -50%);
	border: 3px solid #666;
	display: none;
}

#map-background{
	position: absolute;
	width: 100%;
	height: 100%;
	left: 0;
	top: 0;
	background-color:#000;
	opacity:0.3;
	display: none;
}

/* include/page.jsp의 스타일 가져옴 */
.page_on, .page_off, .page_next, .page_last, .page_first, .page_prev {
	display: inline-block;
	line-height: 30px;
	margin: 0;		
}

.page_on, .page_off {
	min-width:22px;
	padding: 0 5px 2px;
}

.page_next, .page_last, .page_first, .page_prev {
	text-indent: -99999999px;
	border: 1px solid #d0d0d0;
	width: 30px;
}

.page_on {
	border: 1px solid gray;
	background-color: gray;
	color:#FFF;
	font-weight: bold;
}

.page_next { background: url("img/page_next.jpg") center no-repeat; }
.page_last { background: url("img/page_last.jpg") center no-repeat; }
.page_prev { background: url("img/page_prev.jpg") center no-repeat; }
.page_first { background: url("img/page_first.jpg") center no-repeat; }

.list-view, .grid-view { font-size:25px; color:#3367d6; padding-top:3px; }

#list-top ul.common li:not(:last-child) {margin-right: 10px}
#data-list ul.pharmacy li div:first-child { height:25px; }
#data-list ul.pharmacy li div:last-child { font-size:14px; }
</style>
</head>
<body>
<h3>예약 확인 </h3>

<div id="list-top">
	<ul class="common">
		<li>
			<select id="pageList" class="w-px80">
				<option value="10">10개씩</option>
				<option value="20">20개씩</option>
				<option value="30">30개씩</option>
			</select>
		</li>
	</ul>
</div>

<div id="data-list" style="margin:20px 0 auto"></div>

<div class="btnSet">
	<div class="page-list"></div>
</div>

<div id="map-background"></div>
<div id="map"></div> <!-- 지도를 표시할  div -->


<script type="text/javascript">


pharmacy_list(1);

function pharmacy_list(page) {
	$.ajax({
		url:'data/pharmacy',
		data: { pageNo: page, rows:$('#pageList').val() },
		success: function(data) {
			
			console.log(data) //한글이 깨지는 현상 발생해서 commonservice와 컨트롤러에서 utf-8로 인코딩해줘야함
 			var tag = "<table class='pharmacy'>"
 				+ '<tr><th class="w-px200">약국명</th><th class="w-px140" >전화번호</th><th>주소</th></tr>';
				
 			$(data.item).each(function(){
 				tag += "<tr>"
 						+ "<td><a class='map' data-x=" + this.XPos + " data-y=" + this.YPos + ">" + this.yadmNm + "</a></td><td>"
 						+ (this.telno ? this.telno : '-') + "</td><td class='left'>" + this.addr + "</td>"
 					+ "</tr>";
 			});
			
 			tag += "</table>";
 			$('#data-list').html(tag);
			makePage( data.count, page );
		}, error: function(text, req) {
			alert(text + " : " + req.status)
		}
	});
}

function makePage( totalList, curPage ) {
	var page = pageInfo(totalList, curPage, pageList, blockPage);
	var tag = '';

	if ( page.curBlock > 1 ) {
		tag += "<a class='page_first' data-page=1>처음</a>"
			+ "<a class='page_prev'data-page=" + (page.beginPage - blockPage) + ">이전</a>";
	}
	
	for(var no=page.beginPage; no <= page.endPage; no++ ) {
		if( no==curPage ) {
			tag += "<span class='page_on'>" + no + "</span>";
		} else {
			tag += "<a class='page_off' data-page=" + no + ">" + no + "</a>";
		}
	}

	if (page.curBlock < page.totalBlock) {
		tag += "<a class='page_next' data-page=" + (page.endPage + 1) + ">다음</a>"
			+ "<a class='page_last' data-page=" + page.totalPage + ">마지막</a>";
	}
	$('.page-list').html(tag);
}

function pageInfo (totalList, curPage, pageList, blockPage) {
	var page = new Object();
	page.totalPage = parseInt(totalList/pageList) + (totalList % pageList == 0 ? 0 : 1);
	page.totalBlock = parseInt(page.totalPage/blockPage) + (page.totalPage % blockPage == 0 ? 0 : 1);
	page.curBlock = parseInt(curPage/blockPage) + (curPage % blockPage == 0 ? 0 : 1);
	page.endPage =  page.curBlock * blockPage;
	page.beginPage = page.endPage - (blockPage - 1);
	if( page.endPage > page.totalPage ) { page.endPage = page.totalPage; }
	return page;
}



//$('.map').click(function(){  }); 페이지가 다 로딩되기전에 준비되는 함수라 작동이 안될수 있다.
$(document).on('click', '.page-list a', function(){
	pharmacy_list( $(this).data('page') );

}).on('click', '.list-view', function(){
	if( viewType == 'grid' ) {
		viewType="list";
		pharmacy_list_data($('.grid li'), 1);
	}

}).on('click', '.grid-view', function(){
	if( viewType=='list') {
		viewType="grid";
		pharmacy_grid_data( $('.pharmacy tr'), 1);
	}
	
}).on("change", "#pageList", function(){
	pageList = $(this).val();
	pharmacy_list(1);

}).on("click", ".map", function() { //이런 형태로 작성해야한다.
	if( $(this).data('y') == 'undefined' || $(this).data('x') == 'undefined') {
		alert("위경도가 지원되지 않아 지도에 표시할 수 없습니다!");
		return;
	}
	
	$("#map, #map-background").css("display", "block"); // 지도 새창
	
	var mapContainer = document.getElementById('map'), // 지도를 표시할 div 
			mapOption = {
						center: new kakao.maps.LatLng($(this).data('y'), $(this).data('x')), //지도의 중심좌표
						level: 3 // 지도의 확대 레벨
			};
	
	var map = new kakao.maps.Map(mapContainer, mapOption);
	
	// 일반 지도와 스카이뷰로 지도 타입을 전환할 수 있는 지도타입 컨트롤을 생성합니다
	var mapTypeControl = new kakao.maps.MapTypeControl();

	// 지도에 컨트롤을 추가해야 지도위에 표시됩니다
	// kakao.maps.ControlPosition은 컨트롤이 표시될 위치를 정의하는데 TOPRIGHT는 오른쪽 위를 의미합니다
	map.addControl(mapTypeControl, kakao.maps.ControlPosition.TOPRIGHT);

	// 지도 확대 축소를 제어할 수 있는  줌 컨트롤을 생성합니다
	var zoomControl = new kakao.maps.ZoomControl();
	map.addControl(zoomControl, kakao.maps.ControlPosition.RIGHT);
	
	//마커가 표시될 위치입니다
	var markerPosition = new kakao.maps.LatLng($(this).data('y'), $(this).data('x'));
	
	//마커를 생성합니다
	var marker = new kakao.maps.Marker({
			position: markerPosition
	});
	
	// 마커가 지도위에 표시 되도록 설정합니다
	marker.setMap(map);
	
	//인포윈도우에 표출될 내용으로 HTML 문자열이나 document element가 가능합니다
	var iwContent = "<div>" + $(this).text() + "</div>"
	+"<a href='https://map.kakao.com/link/map/"+$(this).text()+","+ $(this).data('y')
	+','+ $(this).data('x') +" ' style='color:blue' target='_blank'>큰지도보기 </a>" 
																											
	+"<a href='https://map.kakao.com/link/to/"+$(this).text()+","+ $(this).data('y')
	+','+ $(this).data('x') +" ' style='color:blue' target='_blank'>길찾기</a>"
	
	+"<a href='#' style='color:blue' target='_blank'> 예약</a>"
	
  		
			//인포윈도우 표시 위치입니다
			iwPosition = new kakao.maps.LatLng($(this).data('y'), $(this).data('x')); 
	
//인포윈도우를 생성합니다
var infowindow = new kakao.maps.InfoWindow({
   position : iwPosition,
   content : iwContent 
});
 
//마커 위에 인포윈도우를 표시합니다. 두번째 파라미터인 marker를 넣어주지 않으면 지도 위에 표시됩니다
infowindow.open(map, marker); 

});

$('#map-background').click(function() {
	$("#map, #map-background").css("display", "none");
});

var pageList = 10, blockPage = 10; //페이지당 보여질 목록 수, 블럭당 보여질 페이지 수


</script>

<!--카카오 API 키 -->
<script src="//dapi.kakao.com/v2/maps/sdk.js?appkey=c2f7b5031616b0f15dace96432c28222"></script>
</body>
</html>