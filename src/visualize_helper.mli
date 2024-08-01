open! Core

val visualize
  :  Matrix.t
  -> current_directory:string
  -> path_to_be_underlined:string
  -> string

val matrix_visualize
  :  max_depth:int
  -> origin:string
  -> show_hidden:bool
  -> sort:bool
  -> unit

val get_name : string -> string
