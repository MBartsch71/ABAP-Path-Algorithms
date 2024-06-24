INTERFACE yif_mbh_bfs
  PUBLIC .
  TYPES: BEGIN OF node,
           id         TYPE string,
           neighbours TYPE stringtab,
         END OF node.
  TYPES graph_nodes TYPE STANDARD TABLE OF node WITH EMPTY KEY.

  TYPES: BEGIN OF visited_node,
           id TYPE string,
         END OF visited_node.
  TYPES visited_nodes TYPE SORTED TABLE OF visited_node WITH UNIQUE KEY table_line.

  TYPES: BEGIN OF parent_node,
           node        TYPE string,
           parent      TYPE string,
           distance_to TYPE i,
         END OF parent_node.
  TYPES parent_nodes TYPE SORTED TABLE OF parent_node WITH UNIQUE KEY table_line.

  TYPES parent_nodes_asc_distance TYPE SORTED TABLE OF parent_node WITH UNIQUE KEY primary_key COMPONENTS node distance_to.

  METHODS get_distance_of_shortest_path IMPORTING start_node    TYPE string
                                                  goal          TYPE string
                                        RETURNING VALUE(result) TYPE string.

  METHODS get_nodes_of_shortest_path IMPORTING start_node    TYPE string
                                               goal          TYPE string
                                     RETURNING VALUE(result) TYPE stringtab.

ENDINTERFACE.
