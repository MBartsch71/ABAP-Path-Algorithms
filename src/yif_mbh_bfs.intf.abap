INTERFACE yif_mbh_bfs
  PUBLIC .
  TYPES: neighbours TYPE STANDARD TABLE OF i WITH EMPTY KEY.
  TYPES: BEGIN OF node,
           id         TYPE i,
           neighbours TYPE neighbours,
         END OF node.
  TYPES graph_nodes TYPE STANDARD TABLE OF node WITH EMPTY KEY.

  TYPES: BEGIN OF visited_node,
           id TYPE i,
         END OF visited_node.
  TYPES visited_nodes TYPE SORTED TABLE OF visited_node WITH UNIQUE KEY table_line.

  TYPES: BEGIN OF parent_node,
           node        TYPE i,
           parent      TYPE i,
           distance_to TYPE i,
         END OF parent_node.
  TYPES parent_nodes TYPE SORTED TABLE OF parent_node WITH UNIQUE KEY table_line.

  TYPES parent_nodes_asc_distance TYPE SORTED TABLE OF parent_node WITH UNIQUE KEY primary_key COMPONENTS node distance_to.

  METHODS get_distance_of_shortest_path IMPORTING goal          TYPE i
                                        RETURNING VALUE(result) TYPE i.

  METHODS get_nodes_of_shortest_path IMPORTING goal          TYPE i
                                     RETURNING VALUE(result) TYPE stringtab.

ENDINTERFACE.
