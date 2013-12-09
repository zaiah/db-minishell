
dbm=/home/zaiah/projects/db_minishell CD=. {
 README.md
 db-minishell.sh
 db.sh
 dbm-old.sh
 dbms.vim
 ms-build.sh
 ms-test.sh
 ms-test-cli.sh
 lib=lib {
  __.sh
  break_list_by_delim.sh
  break_maps_by_delim.sh
  eval_flags.sh
  installation.sh
  is_element_present_in.sh
  tmp_file.sh
 }
 minilib=minilib {
  __.sh
  assemble_clause.sh
  assemble_set.sh
  break_list_by_delim.sh
  break_maps_by_delim.sh
  chop_by_position.sh
  convert.sh
  get_columns.sh
  get_datatypes.sh
  load_from_db_columns.sh
  modify_from_db_columns.sh
 }
 buildlib=buildlib {
  no_conflict.sh
  not_more_than_one.sh
  parse_range.sh
  pick_off.sh
  random_word.sh
 }
 tests=tests {
  dbm-alt-namespace.sh
  dbm-complete.sh
  dbm-no-deps.sh
  dbm-no-extraneous.sh
  dbm-orm.sh
  instances_test_case.sh
  mytest.db
  test-db=test-db {
  }
 }
}
