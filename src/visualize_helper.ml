open! Core

let get_depth_space ~depth =
  List.fold (List.init depth ~f:Fn.id) ~init:"" ~f:(fun acc num ->
    match num = depth - 1 with true -> acc ^ "|__" | false -> acc ^ "  ")
  ^ " "
;;

let is_directory tree ~parent = Hashtbl.mem tree parent
let is_hidden_file name = String.is_prefix name ~prefix:"."

let get_name path =
  match String.contains path '/' with
  | false -> path
  | true -> List.last_exn (String.split path ~on:'/')
;;

let%expect_test "get_name" =
  print_endline (get_name "/home/ubuntu/jsip-final-project");
  print_endline (get_name "dune-project");
  [%expect {|
  jsip-final-project
  dune-project
  |}]
;;

let get_formatted_tree_with_new_parent
  tree
  ~(parent : string)
  ~(depth : int)
  ~(so_far : string)
  =
  match is_directory tree ~parent with
  | true ->
    so_far
    ^ "\n"
    ^ get_depth_space ~depth
    ^ "📁"
    ^ Printf.sprintf "\x1b[36m%s\x1b[37m" (get_name parent)
  | false ->
    (match is_hidden_file (get_name parent) with
     | true ->
       so_far
       ^ "\n"
       ^ get_depth_space ~depth
       ^ Printf.sprintf "\x1b[35m%s\x1b[37m" (get_name parent)
     | false ->
       so_far
       ^ "\n"
       ^ get_depth_space ~depth
       ^ Printf.sprintf "%s" (get_name parent))
;;

let rec helper
  ~(so_far : string)
  (tree : (string, string list) Hashtbl.t)
  ~(depth : int)
  ~(parent : string)
  : string
  =
  match Hashtbl.find tree parent with
  | None -> get_formatted_tree_with_new_parent tree ~parent ~depth ~so_far
  | Some current_children ->
    let init =
      get_formatted_tree_with_new_parent tree ~parent ~depth ~so_far
    in
    List.fold current_children ~init ~f:(fun acc child ->
      helper ~so_far:acc tree ~depth:(depth + 1) ~parent:child)
;;

let visualize
  (tree : (string, string list) Hashtbl.t)
  ~(current_directory : string)
  : string
  =
  helper tree ~depth:1 ~so_far:"." ~parent:current_directory
;;

let%expect_test "visualize" =
  let mat = Hashtbl.create (module String) in
  Hashtbl.add_exn mat ~key:"home" ~data:[ "home_dir1"; "home_dir2" ];
  Hashtbl.add_exn mat ~key:"home_dir1" ~data:[ "child1"; "child2" ];
  Hashtbl.add_exn mat ~key:"home_dir2" ~data:[];
  Hashtbl.add_exn mat ~key:"child1" ~data:[ ".gitignore"; "blah" ];
  let res = visualize mat ~current_directory:"home" in
  print_endline res;
  [%expect
    {|
    .
    |__ home
      |__ home_dir1
        |__ child1
          |__ .gitignore
          |__ blah
        |__ child2
      |__ home_dir2 |}]
;;