open! Core
open! Leaves

type t

type dir =
  | Up
  | Down
  | Left
  | Right

type action =
  | Cursor of dir
  | Shortcut of string
  | Preview
  | Rename
  | Cd
  | Remove
  | Move
  | Summarize

val get_updated_model : t -> action:action -> t
val remove_last_path : string -> string
val get_preview : t -> string
val get_tree : t -> Matrix.t
val get_current_path : t -> string
val get_is_writing : t -> bool
val get_text : t -> Text_input.t
val get_parent : t -> string
val get_summarization : t -> string
val get_is_moving : t -> bool
val should_preview : t -> bool
val should_summarize : t -> bool
val get_model_after_writing : t -> t
val get_model_with_new_text : t -> Text_input.t -> t
val get_model_with_new_current_path : t -> string -> t

val init
  :  choices:Matrix.t
  -> origin:string
  -> current_path:string
  -> parent:string
  -> cursor:int
  -> preview:string
  -> text:Text_input.t
  -> is_writing:bool
  -> show_reduced_tree:bool
  -> is_moving:bool
  -> move_from:string
  -> summarization:string
  -> t
