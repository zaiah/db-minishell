
dbm=/home/zaiah/projects/db_minishell CD=. {
 README.md
 db-minishell.sh
 dbms.vim
 genlibs.sh
 ms-build.sh
 ms-test-cli.sh
 ms-test.sh
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
  chop_by_char.sh
  chop_by_position.sh
  contains.sh
  convert.sh
  load_from_db_columns.sh
  modify_from_db_columns.sh
  parse_schemata.sh
 }
 buildlib=buildlib {
  _libupdate_.sh
  arrtest.sh
  arr.sh
  col_wrap.sh
  help.sh
  in_arr.sh
  is.sh
  no_conflict.sh
  not_more_than_one.sh
  parse_range.sh
  pick_off.sh
  random_word.sh
 }
 tests=tests {
  d.db
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
