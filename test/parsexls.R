.parsexls <- function(file) {
  
  ##read in xls file
  c(num, text, raw) <- xlsread(file)
  ##parse
  Samples <- txt[2:nrow(txt), 1]
  IC50s <- num[, 2]
  
  MutationMatrix <- num[, 3:ncol(num)]
  Features <- txt[1, 3:ncol(txt)]
  
  return(c(Samples, Features, IC50s, MutationMatrix))
}