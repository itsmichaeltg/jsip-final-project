open! Core

type t = (string, string list) Hashtbl.t [@@deriving sexp_of]

let find (t : t) b = Hashtbl.find t b
let find_exn (t : t) b = Hashtbl.find_exn t b
let mem (t : t) a = Hashtbl.mem t a
let set (t : t) ~key ~data = Hashtbl.set t ~key ~data
let create () = Hashtbl.create (module String)
let is_directory t (value : string) = mem t value
let hidden str = Char.equal (String.nget str 0) '.'
let add_exn (t : t) ~key ~data = Hashtbl.add_exn t ~key ~data

let get_name path =
  match String.contains path '/' with
  | false -> path
  | true -> List.last_exn (String.split path ~on:'/')
;;

let is_directory t (value : string) = mem t value
let get_children t path = find t path

let write_and_read origin =
  let write_path = "/home/ubuntu/jsip-final-project/bin/files.txt" in
  let _ =
    Format.sprintf "ls -t %s > %s" origin write_path |> Sys_unix.command
  in
  In_channel.read_lines write_path
;;

let get_files_in_dir origin ~show_hidden ~sort =
  let data =
    if not sort
    then (try Sys_unix.ls_dir origin with _ -> [])
    else write_and_read origin
  in
  if show_hidden
  then data
  else List.filter data ~f:(fun i -> hidden i |> not)
;;

let rec get_adjacency_matrix t ~sort ~show_hidden ~origin ~max_depth =
  match max_depth with
  | 0 ->
    (match Sys_unix.is_directory origin with
     | `Yes -> add_exn t ~key:origin ~data:[]
     | _ -> ());
    t
  | _ ->
    let data =
      List.map (get_files_in_dir origin ~show_hidden ~sort) ~f:(fun i ->
        String.concat [ origin; "/"; i ])
    in
    add_exn t ~key:origin ~data;
    List.fold ~init:t data ~f:(fun _ i ->
      match Sys_unix.is_directory i with
      | `Yes ->
        get_adjacency_matrix
          t
          ~origin:i
          ~max_depth:(max_depth - 1)
          ~show_hidden
          ~sort
      | _ -> get_adjacency_matrix t ~origin:i ~max_depth:0 ~show_hidden ~sort)
;;

let rec get_limited_adjacency_matrix
  t
  ~sort
  ~show_hidden
  ~origin
  ~max_depth
  ~num_to_show
  =
  match max_depth with
  | 0 ->
    (match Sys_unix.is_directory origin with
     | `Yes -> add_exn t ~key:origin ~data:[]
     | _ -> ());
    t
  | _ ->
    let children = get_files_in_dir origin ~show_hidden ~sort in
    let limited_children =
      List.slice children 0 (Int.min num_to_show (List.length children))
    in
    let data =
      List.map limited_children ~f:(fun i ->
        String.concat [ origin; "/"; i ])
    in
    add_exn t ~key:origin ~data;
    List.fold ~init:t data ~f:(fun _ i ->
      match Sys_unix.is_directory i with
      | `Yes ->
        get_limited_adjacency_matrix
          t
          ~origin:i
          ~max_depth:(max_depth - 1)
          ~num_to_show
          ~show_hidden
          ~sort
      | _ ->
        get_limited_adjacency_matrix
          t
          ~origin:i
          ~max_depth:0
          ~num_to_show
          ~show_hidden
          ~sort)
;;