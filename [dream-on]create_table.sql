-- board 테이블 생성
CREATE TABLE `board` (
  `post_id` int(11) NOT NULL AUTO_INCREMENT,
  `board_type` varchar(30) NOT NULL,
  `user_id` int(11) NOT NULL,
  `title` varchar(200) NOT NULL,
  `content` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `view_count` int(11) DEFAULT 0,
  `status` varchar(20) DEFAULT NULL,
  `priority` varchar(20) DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `category` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`post_id`),
  KEY `board_fk_user_id` (`user_id`),
  CONSTRAINT `board_fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- category 테이블 생성
CREATE TABLE `category` (
  `category_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '카테고리 대분류 식별자',
  `category` varchar(150) NOT NULL COMMENT '카테고리 대분류 이름',
  PRIMARY KEY (`category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- comment 테이블 생성
CREATE TABLE `comment` (
  `comment_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '댓글 식별자',
  `project_id` int(11) NOT NULL COMMENT '댓글이 달린 캠페인 id',
  `user_id` int(11) NOT NULL COMMENT '댓글 작성자 id',
  `comment` longtext NOT NULL COMMENT '댓글 내용',
  `like_count` int(11) DEFAULT 0,
  `post_date` datetime NOT NULL DEFAULT current_timestamp() COMMENT '댓글을 단 시점',
  PRIMARY KEY (`comment_id`),
  KEY `comment_fk_project_id` (`project_id`),
  KEY `comment_fk_user_id` (`user_id`),
  CONSTRAINT `comment_fk_project_id` FOREIGN KEY (`project_id`) REFERENCES `project` (`project_id`),
  CONSTRAINT `comment_fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=114 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- donation 테이블 생성
CREATE TABLE `donation` (
  `donation_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '기부 내역 식별자',
  `user_id` int(11) NOT NULL COMMENT '기부자 id',
  `project_id` int(11) NOT NULL COMMENT '기부 프로젝트 id',
  `donation_amount` int(11) NOT NULL DEFAULT 0 COMMENT '기부 금액',
  `donation_date` datetime NOT NULL DEFAULT current_timestamp() COMMENT '기부 시점',
  `payment_method` varchar(50) DEFAULT NULL COMMENT '결제 방식(예: 카드, 계좌이체, 간편결제 등)',
  `status` varchar(20) DEFAULT 'success' COMMENT '기부 상태(예: success, failed, cancelled 등)',
  PRIMARY KEY (`donation_id`),
  KEY `donation_fk_user_id` (`user_id`),
  KEY `donation_fk_project_id` (`project_id`),
  CONSTRAINT `donation_fk_project_id` FOREIGN KEY (`project_id`) REFERENCES `project` (`project_id`),
  CONSTRAINT `donation_fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=76 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- notification 테이블 생성
CREATE TABLE `notification` (
  `notification_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '알림 식별자',
  `user_id` int(11) NOT NULL COMMENT '알림 수신자 id',
  `type` varchar(50) NOT NULL COMMENT '알림 유형(예: project_update, comment, system_msg 등)',
  `message` varchar(200) DEFAULT NULL COMMENT '알림 내용',
  `timestamp` datetime NOT NULL DEFAULT current_timestamp() COMMENT '알림 생성 시각',
  `status` varchar(20) DEFAULT 'unread' COMMENT '알림 상태(예: unread, read, deleted 등)',
  `project_id` int(11) DEFAULT NULL COMMENT '기부 프로젝트 id(특정 프로젝트 관련 알림인 경우)',
  PRIMARY KEY (`notification_id`),
  KEY `notification_fk_user_id` (`user_id`),
  KEY `notification_fk_project_id` (`project_id`),
  CONSTRAINT `notification_fk_project_id` FOREIGN KEY (`project_id`) REFERENCES `project` (`project_id`),
  CONSTRAINT `notification_fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- project 테이블 생성
CREATE TABLE `project` (
  `project_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '프로젝트 식별자',
  `category_id` int(11) NOT NULL COMMENT '프로젝트 카테고리 소분류 id',
  `title` varchar(100) NOT NULL COMMENT '프로젝트(펀딩) 제목',
  `user_id` int(11) NOT NULL COMMENT '프로젝트 생성(수혜)자 id',
  `target_amount` int(11) DEFAULT 0 COMMENT '목표 금액',
  `start_date` datetime NOT NULL DEFAULT current_timestamp() COMMENT '모금 시작 일자',
  `end_date` datetime DEFAULT NULL COMMENT '모금 마감 일자',
  `status` varchar(20) NOT NULL DEFAULT 'pending' COMMENT '프로젝트 상태(예: pending, active, completed, cancelled 등)',
  `description` longtext DEFAULT NULL COMMENT '상세 설명(스토리, 이미지URL 등)',
  `created_at` datetime NOT NULL DEFAULT current_timestamp() COMMENT '등록 일자',
  `updated_at` datetime DEFAULT current_timestamp() COMMENT '수정 일자',
  `approval_date` datetime DEFAULT NULL COMMENT '관리자 승인 일자(승인 시점 기록)',
  `project_image` varchar(200) DEFAULT NULL COMMENT '프로젝트 이미지 경로',
  `like_count` int(11) DEFAULT 0 COMMENT '종아요 수',
  `share_count` int(11) DEFAULT 0 COMMENT '공유한 횟수',
  PRIMARY KEY (`project_id`),
  KEY `project_fk_user_id` (`user_id`),
  KEY `project_fk_category_id` (`category_id`),
  CONSTRAINT `project_category_FK` FOREIGN KEY (`category_id`) REFERENCES `category` (`category_id`),
  CONSTRAINT `project_fk_category_id` FOREIGN KEY (`category_id`) REFERENCES `category` (`category_id`),
  CONSTRAINT `project_fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=205 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- user 테이블 생성
CREATE TABLE `user` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '사용자 식별자',
  `email` varchar(100) NOT NULL COMMENT '로그인/연락용 이메일',
  `password_hash` varchar(200) NOT NULL COMMENT '비밀번호 해시',
  `user_name` varchar(50) NOT NULL COMMENT '사용자 닉네임/이름',
  `gender` varchar(10) DEFAULT '남성' COMMENT '성별',
  `phone` varchar(15) DEFAULT NULL COMMENT '전화번호',
  `user_type` varchar(20) NOT NULL DEFAULT 'donor' COMMENT '계정 유형(예: donor, applicant, admin)',
  `balance` int(11) DEFAULT 0 COMMENT '보유 금액',
  `created_at` datetime NOT NULL DEFAULT current_timestamp() COMMENT '가입 일자',
  `updated_at` datetime DEFAULT current_timestamp() COMMENT '회원 정보 수정 일자',
  `is_active` char(1) DEFAULT 'Y' COMMENT '활성화 여부(Y/N)',
  `profile_image` varchar(200) DEFAULT NULL COMMENT '프로필 이미지 경로',
  `reset_token` varchar(200) DEFAULT NULL COMMENT '임시 비밀번호',
  `reset_token_expires_at` datetime DEFAULT NULL COMMENT '임시 비밀번호 유효기간',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=59 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;