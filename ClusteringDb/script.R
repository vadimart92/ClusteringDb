#https://github.com/thomasp85/ggraph

rm(list = ls())

library(igraph)
library(ggraph)
library(RODBC)

dbhandle <- odbcDriverConnect('driver={SQL Server};server=ARTEMCHUKPC\\MSSQL2016;Integrated Security=True;database=Work_770_2555_va')
nodes.dependencies <- sqlQuery(dbhandle, 'select * from Node')
nodes.info <- sqlQuery(dbhandle, 'select * from Node_Info')
graph <- graph.data.frame(nodes.dependencies)
summary(graph)
uc <- as.undirected(graph, mode = "collapse")
ue <- as.undirected(graph, mode = "each")
uc <- simplify(uc, remove.multiple = TRUE, remove.loops = TRUE, edge.attr.comb = igraph_opt("edge.attr.comb"))
ue <- simplify(ue, remove.multiple = TRUE, remove.loops = TRUE, edge.attr.comb = igraph_opt("edge.attr.comb"))
com <- cluster_fast_greedy(uc, merges = TRUE, modularity = TRUE, membership = TRUE)
#com <- cluster_edge_betweenness(graph, directed = TRUE, edge.betweenness = TRUE, merges = TRUE, bridges = TRUE, modularity = TRUE, membership = TRUE)
com <- cluster_louvain(graph)