RED='\033[0;31m'
NO_COLOR='\033[0m'
alias db="psql"

alias dbdev="PGPASSWORD='$DEVELOP_DBPASS' psql -h $DEVELOP_DBHOST -U $DEVELOP_DBUSERNAME"
alias dbtest="PGPASSWORD='$TEST_DBPASS' psql -h $TEST_DBHOST -U $TEST_DBUSERNAME"
alias dbstage="PGPASSWORD='$STAGE_DBPASS' psql -h $STAGE_DBHOST -U $STAGE_DBUSERNAME"
alias dblive="PGPASSWORD='$LIVE_DBPASS' psql -h $LIVE_DBHOST -U $LIVE_DBUSERNAME"

dump() {
	[ -z $2 ] && TARGET=local || TARGET=$2
	case $TARGET in
		develop)
			PGPASSWORD=$DEVELOP_DBPASS pg_dump -h $DEVELOP_DBHOST -U $DEVELOP_DBUSERNAME -c $1 -F t >| $DB_BACKUP_DIR/$TARGET/$1.tar
		;;
		test)
			PGPASSWORD=$TEST_DBPASS pg_dump -h $TEST_DBHOST -U $TEST_DBUSERNAME -c $1 -F t >| $DB_BACKUP_DIR/$TARGET/$1.tar
		;;
		stage)
			PGPASSWORD=$STAGE_DBPASS pg_dump -h $STAGE_DBHOST -U $STAGE_DBUSERNAME -c $1 -F t >| $DB_BACKUP_DIR/$TARGET/$1.tar
		;;
		live)
			PGPASSWORD=$LIVE_DBPASS pg_dump -h $LIVE_DBHOST -U $LIVE_DBUSERNAME -c $1 -F t >| $DB_BACKUP_DIR/$TARGET/$1.tar
		;;
		local)
			pg_dump -c $1 -F t >| $DB_BACKUP_DIR/$TARGET/$1.tar
		;;
	esac
}
restore() {
	[ -z $2 ] && TARGET=local || TARGET=$2
	[ -z $3 ] && SOURCE=$TARGET || SOURCE=$3
	echo Taget is..
	echo $TARGET
	echo Source is..
	echo $SOURCE
	case $TARGET in
		develop)
			dbdev $1 < $DB_BACKUP_DIR/$SOURCE/$1.tar
		;;
		test)
			dbtest $1 < $DB_BACKUP_DIR/$SOURCE/$1.tar
		;;
		stage)
			dbstage $1 < $DB_BACKUP_DIR/$SOURCE/$1.tar
		;;
		live)
			echo -e "${RED}Error!${NO_COLOR} Live restore is not supported."
			return
			# psql -h $LIVE_DBHOST -U $LIVE_DBHOST $1 < $DB_BACKUP_DIR/$SOURCE/$1.tar
		;;
		local)
			psql $1 < $DB_BACKUP_DIR/$SOURCE/$1.tar
		;;
	esac
}

