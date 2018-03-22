#* @get /sampleGetOpt
sampleOpt <- function(observations){
  sample(1:100, as.numeric(observations), replace = TRUE)
}
#* @get /sampleNoReplaceGetOpt
sampleOpt <- function(observations){
  sample(1:100, as.numeric(observations), replace = FALSE)
}
#* @post /normalOpt
normalOpt <- function(observations, mean, standardDeviation){
  rnorm(as.numeric(observations), as.numeric(mean), as.numeric(standardDeviation))
}
#* @get /normalGetOpt
normalOpt <- function(observations, mean, standardDeviation){
  rnorm(as.numeric(observations), as.numeric(mean), as.numeric(standardDeviation))
}
#* @get /uniformGetOpt
uniformOpt <- function(observations, minimum, maximum){
  runif(as.numeric(observations), as.numeric(minimum), as.numeric(maximum))
}
#* @get /exponentialGetOpt
exponentialOpt <- function(observations, rate){
  rexp(as.numeric(observations), as.numeric(rate))
}
