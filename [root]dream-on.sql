create database `dream-on`; -- dream-on 데이터베이스 생성

create user 'dream-on'@'%' identified by '1234'; -- dream-on 유저 생성

grant all privileges on `dream-on`.* to 'dream-on'@'%'; -- dream-on 유저에게 dream-on 데이터베이스의 모든 권한 부여