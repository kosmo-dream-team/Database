/* ------------------------------------ 테이블 생성 --------------------------------------- */
-- 사용자 테이블 생성
create table `user`(
	user_id int not null auto_increment primary key comment '사용자 식별자',
	email varchar(100) not null unique comment '로그인/연락용 이메일',
	password_hash varchar(200) not null comment '비밀번호 해시',
	user_name varchar(50) not null comment '사용자 닉네임/이름',
	user_type varchar(20) not null default 'donor' comment '계정 유형(예: donor, applicant, admin)',
	`rank` varchar(20) default '브론즈' comment '기부 등급(예: 브론즈, 실버, 골드)',
	created_at datetime not null default now() comment '가입 일자',
	updated_at datetime default now() comment '회원 정보 수정 일자',
	is_active char(1) default 'Y' comment '활성화 여부(Y/N)',
	profile_image varchar(200) comment '프로필 이미지 경로'
);

-- 보유 금액 컬럼 추가
alter table `user` add column balance int default 0 after user_type;
-- 성별, 전화번호 컬럼 추가
alter table `user` add column gender varchar(10) default '남성' after user_name;
alter table `user` add column phone varchar(15) after gender;
-- 임시 비밀번호, 임시 비밀번호 유효기간 컬럼 추가
alter table `user` add column reset_token varchar(200) comment '임시 비밀번호';
alter table `user` add column reset_token_expires_at datetime comment '임시 비밀번호 유효기간'; 
-- 기부 액수에 따라 결정되는 것으로 변경된 rank 컬럼 삭제
alter table `user` drop column `rank`;

-- comment 추가 에러 컬럼 별도로 comment 추가
alter table `user` modify balance int default 0 comment '보유 금액';
alter table `user` modify gender varchar(10) default '남성' comment '성별';
alter table `user` modify phone varchar(15) comment '전화번호';

-- 생성된 테이블 확인
select * from user;

-- 기부 프로젝트 관리 테이블 생성
create table `project`(
	project_id int not null auto_increment primary key comment '프로젝트 식별자',
	title varchar(100) not null comment '프로젝트(펀딩) 제목',
	category varchar(50) comment '카테고리(아동, 동물, 환경 등)',
	user_id int not null comment '프로젝트 생성(수혜)자 id',
	target_amount int default 0 comment '목표 금액',
	start_date datetime not null default now() comment '모금 시작 일자',
	end_date datetime,
	status varchar(20) not null default 'pending' comment '프로젝트 상태(예: pending, active, completed, cancelled 등)',
	description longtext,
	created_at datetime not null default now() comment '등록 일자',
	updated_at datetime default now() comment '수정 일자',
	approval_date datetime
);
-- 캠페인 상세 페이지 작업에 필요한 컬럼 추가
alter table project add column project_image varchar(200) comment '프로젝트 이미지 경로';
alter table project add column `like` int default 0 comment '종아요 수';
alter table project add column share_count int default 0 comment '공유한 횟수';
-- 카테고리를 DB에서 관리하기로 결정되어 해당 내용에 관련된 컬럼 변경
alter table project drop column category;
alter table project add column category_id int not null comment '프로젝트 카테고리 소분류 id' after project_id;
-- like 컬럼 이름 통일
alter table project change `like` like_count int; 

-- comment 추가 에러 컬럼 별도로 comment 추가
alter table project modify end_date datetime comment '모금 마감 일자';
alter table project modify description longtext comment '상세 설명(스토리, 이미지URL 등)';
alter table project modify approval_date datetime comment '관리자 승인 일자(승인 시점 기록)';	

-- 생성된 테이블 확인
select * from project;

-- 기부 내역 테이블 생성
create table `donation`(
	donation_id int not null auto_increment primary key comment '기부 내역 식별자',
	user_id int not null comment '기부자 id',
	project_id int not null comment '기부 프로젝트 id',
	donation_amount int not null default 0 comment '기부 금액',
	donation_date datetime not null default now() comment '기부 시점',
	payment_method varchar(50) comment '결제 방식(예: 카드, 계좌이체, 간편결제 등)',
	status varchar(20) default 'success' comment '기부 상태(예: success, failed, cancelled 등)'
);

-- 생성된 테이블 확인
select * from donation;

-- 알림 테이블 생성
create table `notification`(
	notification_id int not null auto_increment primary key comment '알림 식별자',
	user_id int not null comment '알림 수신자 id',
	`type` varchar(50) not null comment '알림 유형(예: project_update, comment, system_msg 등)',
	message varchar(200) comment '알림 내용',
	`timestamp` datetime not null default now() comment '알림 생성 시각',
	status varchar(20) default 'unread' comment '알림 상태(예: unread, read, deleted 등)',
	project_id int
);
-- comment 추가 에러 컬럼 별도로 comment 추가
alter table notification modify project_id int comment '기부 프로젝트 id(특정 프로젝트 관련 알림인 경우)';

-- 생성된 테이블 확인
select * from notification;

-- Q&A 게시판 테이블 생성
create table `qna_board`(
	post_id int not null auto_increment primary key comment '게시글 식별자',
	user_id int not null comment '게시글 작성자 id',
	title varchar(200) not null comment '게시글 제목',
	content longtext not null comment '게시글 내용',
	created_at datetime not null default now() comment '작성 날짜',
	updated_at datetime default now() comment '수정 날짜',
	is_active char(1) not null default 'Y' comment '활성화 상태(Y/N)',
	category varchar(50) comment '질문 카테고리(예: 기술, 계정 관련 등)',
	status varchar(20) not null default 'open' comment '질문 상태(예: open, answered)'
);

-- 생성된 테이블 확인
select * from qna_board;
-- qna_board 테이블 삭제 요청
drop table qna_board;

-- 공지사항 게시판 테이블 생성
create table `notice_board`(
	post_id int not null auto_increment primary key comment '게시글 식별자',
	user_id int not null comment '게시글 작성자 id',
	title varchar(200) not null comment '게시글 제목',
	content longtext not null comment '게시글 내용',
	created_at datetime not null default now() comment '작성 날짜',
	updated_at datetime default now() comment '수정 날짜',
	is_active char(1) not null default 'Y' comment '활성화 상태(Y/N)',
	priority varchar(20) default 'normal' comment '우선순위(예: normal, high 등)'
);

-- 생성된 테이블 확인
select * from notice_board;
-- notice_board 테이블 삭제 요청
drop table notice_board;

-- 후원 소감 게시판 테이블 생성
create table `donation_feedback_board`(
	post_id int not null auto_increment primary key comment '게시글 식별자',
	user_id int not null comment '게시글 작성자 id',
	title varchar(200) not null comment '게시글 제목',
	content longtext not null comment '게시글 내용',
	created_at datetime not null default now() comment '작성 날짜',
	updated_at datetime default now() comment '수정 날짜',
	is_active char(1) not null default 'Y' comment '활성화 상태(Y/N)',
	project_id int,
	image varchar(255) comment '첨부 이미지 URL'
);
-- comment 추가 에러 컬럼 별도로 comment 추가
alter table donation_feedback_board modify project_id int comment '관련 프로젝트 id';

-- 생성된 테이블 확인
select * from donation_feedback_board;
-- donation_feedback_board 테이블 삭제 요청
drop table donation_feedback_board;

-- FAQ 게시판 테이블 생성
create table `faq_board`(
	post_id int not null auto_increment primary key comment '게시글 식별자',
	user_id int not null comment '게시글 작성자 id',
	title varchar(200) not null comment '게시글 제목',
	content longtext not null comment '게시글 내용',
	created_at datetime not null default now() comment '작성 날짜',
	updated_at datetime default now() comment '수정 날짜',
	is_active char(1) not null default 'Y' comment '활성화 상태(Y/N)',
	category varchar(50) comment '질문 카테고리(예: 서비스, 기부 등)'
);

-- 생성된 테이블 확인
select * from faq_board;
-- faq_board 테이블 삭제 요청
drop table faq_board;

-- 기부 프로젝트 댓글 테이블 생성
create table `comment`(
	comment_id int not null auto_increment primary key comment '댓글 식별자',
	project_id int not null comment '댓글이 달린 캠페인 id',
	user_id int not null comment '댓글 작성자 id',
	comment longtext not null comment '댓글 내용',
	`like` int default 0 comment '댓글 좋아요 수', 
	post_date datetime not null default now() comment '댓글을 단 시점'
);
-- 컬럼 이름 변경
alter table comment change `like` like_count int default 0;

-- 생성된 테이블 확인
select * from comment;

-- 기부 카테고리 대분류 테이블 생성
create table `category`(
	category_id int not null auto_increment primary key comment '카테고리 대분류 식별자',
	category varchar(150) not null comment '카테고리 대분류 이름'
);

-- 생성된 테이블 확인
select * from category;

-- 기부 카테고리 소분류 테이블 생성
create table `sub_category`(
	sub_category_id int not null auto_increment primary key comment '카테고리 소분류 식별자',
	category_id int not null comment '카테고리 대분류 id',
	sub_category varchar(150) not null comment '카테고리 소분류 이름'
);

-- 생성된 테이블 확인
select * from sub_category;
-- sub_category 테이블 삭제 요청
drop table sub_category;

/* ------------------------------------ 외래 키 설정 --------------------------------------- */
-- project 테이블 외래 키 생성
alter table `project` add constraint project_fk_user_id foreign key(user_id) references `user`(user_id);
alter table `project` add constraint project_fk_category_id foreign key(category_id) references `sub_category`(sub_category_id);
-- sub_category 테이블 삭제 요청으로 인한 외래 키 삭제
alter table project drop constraint project_fk_category_id;
-- sub_category 테이블 삭제 이후 category 테이블과 연결
alter table project add constraint project_fk_category_id foreign key(category_id) references `category`(category_id);

-- donation 테이블 외래 키 생성
alter table `donation` add constraint donation_fk_user_id foreign key(user_id) references `user`(user_id);
alter table `donation` add constraint donation_fk_project_id foreign key(project_id) references `project`(project_id);

-- notification 테이블 외래 키 생성
alter table `notification` add constraint notification_fk_user_id foreign key(user_id) references `user`(user_id);
alter table `notification` add constraint notification_fk_project_id foreign key(project_id) references `project`(project_id);

-- qna_board 테이블 외래 키 생성
alter table `qna_board` add constraint qna_board_fk_user_id foreign key(user_id) references `user`(user_id);
-- qna_board 테이블 삭제 요청으로 인한 외래 키 삭제
alter table qna_board drop constraint qna_board_fk_user_id;

-- notice_board 테이블 외래 키 생성
alter table `notice_board` add constraint notice_board_fk_user_id foreign key(user_id) references `user`(user_id);
-- notice_board 테이블 삭제 요청으로 인한 외래 키 삭제
alter table notice_board drop constraint notice_board_fk_user_id;

-- donation_feedback_board 테이블 외래 키 생성
alter table `donation_feedback_board` add constraint donation_feedback_board_fk_user_id foreign key(user_id) references `user`(user_id);
alter table `donation_feedback_board` add constraint donation_feedback_board_fk_project_id foreign key(project_id) references `project`(project_id);
-- donation_feedback_board 테이블 삭제 요청으로 인한 외래 키 삭제
alter table donation_feedback_board drop constraint donation_feedback_board_fk_user_id;
alter table donation_feedback_board drop constraint donation_feedback_board_fk_project_id;

-- faq_board 테이블 외래 키 생성
alter table `faq_board` add constraint faq_board_fk_user_id foreign key(user_id) references `user`(user_id);
-- faq_board 테이블 삭제 요청으로 인한 외래 키 삭제
alter table faq_board drop constraint faq_board_fk_user_id;

-- comment 테이블 외래 키 생성
alter table `comment` add constraint comment_fk_project_id foreign key(project_id) references `project`(project_id);
alter table `comment` add constraint comment_fk_user_id foreign key(user_id) references `user`(user_id);

-- sub_category 테이블 외래 키 생성
alter table sub_category add constraint sub_category_fk_category_id foreign key(category_id) references `category`(category_id);
-- sub_category 테이블 삭제 요청으로 인한 외래 키 삭제
alter table sub_category drop constraint sub_category_fk_category_id;

-- board 테이블 외래 키 생성
alter table board add constraint board_fk_user_id foreign key(user_id) references user(user_id);

/* ----------------------------------- FAQ 데이터 입력 쿼리 -------------------------------------- */
-- faq 등록에 필요한 관리자 계정 생성
insert into `user`(email, password_hash, user_name, user_type) values('choijunyoung0212@gmail.com', '$2y$10$Gja9F/.4Vt09OAz1vHJFWe/vrQEqV9yH0abqvu16u.M8RuQS6E3De', '최준영', 'admin');

-- FAQ 데이터 추가
insert into `faq_board`(user_id, title, content, is_active) values(1, 'DREAM ON은 어떤 기부 플랫폼인가요?', 'DREAM ON은 기부자와 도움이 필요한 수혜자를 연결하는 플랫폼입니다.\n이동, 의료, 장애인 지원, 교육 등 다양한 카테고리에서 기부할 수 있으며,\n기부 통계를 확인하고 캠페인에 참여할 수도 있습니다.', 'Y');
insert into `faq_board`(user_id, title, content, is_active) values(1, '기부는 어떻게 진행되나요?', '원하는 기부 카테고리를 선택한 후,\n현재 가장 많이 기부 중인 프로젝트를 확인하거나,\n개별 캠페인 페이지에서 기부할 수 있습니다.\n결제 후, 마이페이지에서 기부 내역을 확인할 수 있습니다.', 'Y');
insert into `faq_board`(user_id, title, content, is_active) values(1, '내가 한 기부가 실제로 사용되는지 어떻게 확인할 수 있나요?', 'DREAM ON에서는 기부금 사용 내역을 투명하게 공개합니다.\n\n마이페이지 > 기부 내역에서 상세 정보를 확인할 수 있습니다.\n모금 목표 달성 후, 수혜자의 후기나 진행 상황을 업데이트합니다.', 'Y');
insert into `faq_board`(user_id, title, content, is_active) values(1, '소액 기부도 가능한가요?', '네, 가능합니다. DREAM ON은 최소 1,000원부터 기부할 수 있으며,\n소액이라도 많은 사람의 기부가 모이면 큰 도움이 될 수 있습니다.', 'Y');
insert into `faq_board`(user_id, title, content, is_active) values(1, '기부자 인증 배지는 무엇인가요?', 'DREAM ON에서는 기부자 활동을 격려하기 위해\n기부 횟수와 금액에 따라 인증 배지를 부여합니다.\n예를 들어, "착한 기부자", "정기 기부자" 등의 배지를 받을 수 있습니다.', 'Y');
insert into `faq_board`(user_id, title, content, is_active) values(1, '정기 기부를 설정할 수 있나요?', '네, 가능합니다.\n\n한 달에 한 번 혹은 주 단위로 자동 기부 설정이 가능합니다.\n정기 기부는 마이페이지에서 언제든지 해지할 수 있습니다.', 'Y');
insert into `faq_board`(user_id, title, content, is_active) values(1, '기부 후 환불이 가능한가요?', '일회성 기부는 환불이 불가능합니다.\n하지만, 정기 기부는 언제든 해지 가능하며,\n일정 기간 미처리된 기부금은 고객센터를 통해 처리할 수 있습니다.', 'Y');
insert into `faq_board`(user_id, title, content, is_active) values(1, '기부 대상은 어떻게 선정되나요?', 'DREAM ON에서는 신뢰할 수 있는 기관 및 개인을 대상으로 심사 후 등록합니다.\n\n병원, 사회복지기관, 공익 단체 등이 등록할 수 있습니다.\n개인 신청자의 경우, 심사를 거쳐야 캠페인 등록이 가능합니다.', 'Y');
insert into `faq_board`(user_id, title, content, is_active) values(1, 'DREAM ON에서 물품 기부도 가능한가요?', '현재는 금전 기부 중심으로 운영하고 있지만,\n특정 캠페인에서는 의류, 생필품, 학용품 등 물품 기부도 가능합니다.\n자세한 사항은 캠페인 페이지를 확인하세요.', 'Y');
insert into `faq_board`(user_id, title, content, is_active) values(1, '기부 외에도 봉사 활동을 할 수 있나요?', '네, DREAM ON에서는 기부뿐만 아니라 봉사 참여 기능도 지원합니다.\n\n게시판에서 봉사 모집 정보를 확인할 수 있으며,\n지역별 봉사 프로그램을 신청할 수도 있습니다.', 'Y');

select * from `faq_board`;

/* --------------------------------- 카테고리 데이터 입력 쿼리 ------------------------------------- */
-- 카테고리 대분류 추가
insert into `category`(category) values('아동ㆍ청소년');
insert into `category`(category) values('동물');
insert into `category`(category) values('장애인');
insert into `category`(category) values('환경');
insert into `category`(category) values('어르신/사회');

-- 카테고리 소분류 추가
insert into `sub_category`(category_id, sub_category) values(1, '자립준비청년 지원');
insert into `sub_category`(category_id, sub_category) values(1, '한부모가족 지원');
insert into `sub_category`(category_id, sub_category) values(1, '해외어린이 긴급구호');
insert into `sub_category`(category_id, sub_category) values(1, '아픈 어린이 의료비 지원');
insert into `sub_category`(category_id, sub_category) values(1, '위기가정아동 지원');
insert into `sub_category`(category_id, sub_category) values(2, '유기동물 입양 문화 정착');
insert into `sub_category`(category_id, sub_category) values(2, '유기동물 구조와 보호');
insert into `sub_category`(category_id, sub_category) values(2, '제주 남방큰돌고래 보호');
insert into `sub_category`(category_id, sub_category) values(2, '길고양이 치료와 보호');
insert into `sub_category`(category_id, sub_category) values(3, '장애어린이 재활 지원');
insert into `sub_category`(category_id, sub_category) values(3, '장애청년 예술 지원');
insert into `sub_category`(category_id, sub_category) values(4, '도시 속 나무 심기');
insert into `sub_category`(category_id, sub_category) values(4, '쓰레기 문제 해결');
insert into `sub_category`(category_id, sub_category) values(5, '청년 고립 극복 지원');
insert into `sub_category`(category_id, sub_category) values(5, '독립유공자 후손 지원');
insert into `sub_category`(category_id, sub_category) values(5, '어르신 기본 생활 지원');


/* ------------------------------------ 프로젝트 API 쿼리 --------------------------------------- */
-- Project/SELECT/캠페인 수 확인
select count(project_id) as 'project_count' from project;

-- Donation/SELECT/총기부금, 기부횟수 확인
select ifnull(sum(donation_amount), 0) as 'total_donation_amount', count(donation_id) as 'total_donation_count' from donation;

-- Donation/SELECT/월별 기부금 (최근 12개월)
select year(donation_date) as 'donation_year', month(donation_date) as 'donation_month', ifnull(sum(donation_amount), 0) as 'amount'
from donation 
group by year(donation_date), month(donation_date) 
order by year(donation_date) desc, month(donation_date) desc 
limit 12;

-- User, Donation/SELECT, JOIN/나의 보유금액, 총후원금액 확인
select u.balance, ifnull(sum(d.donation_amount), 0) as 'my_total_donation_amount' from user u left join donation d on d.user_id = u.user_id where u.user_id = 1;

-- User/SELECT/이메일, 비밀번호 일치 여부 확인
select count(user_id) from user where email = 'choijunyoung0212@gmail.com' and password_hash = '$2y$10$Gja9F/.4Vt09OAz1vHJFWe/vrQEqV9yH0abqvu16u.M8RuQS6E3De';

-- User/INSERT/이메일, 이름, 비밀번호 입력
insert into `user`(email, password_hash, user_name, user_type) values('', '', '', 'donor');

-- Project/SELECT(UNIQUE)/카데고리 확인
select * from project where category = '' and status = 'active' and end_date > now();

-- Project, Donation/SELECT/프로젝트 기부금순(Active) Top3 확인
select p.* 
from project p
left join donation d on d.project_id = p.project_id
where p.status = 'active' and p.end_date > now() 
order by ifnull(sum(d.donation_amount), 0) desc
limit 3;

-- Project, Donation/SELECT/프로젝트 기부금순(Active) Top10 확인
select p.* 
from project p
left join donation d on d.project_id = p.project_id
where p.status = 'active' and p.end_date > now() 
order by ifnull(sum(d.donation_amount), 0) desc
limit 10;

-- 후원소감/SELECT/*(Active) 최근 10개 확인
select * from donation_feedback_board where is_active = 'Y' order by updated_at desc limit 10;

-- Project/SELECT/프로젝트 시작일순(Active) Top3 확인
select * from project where start_date < now() and now() < end_date and status = 'active' order by start_date desc limit 3;