#context("countsFuns")

data(testingCounts)

test_that("check moveGenesToRownames", {

  #setup expected data
  e.rownames <- c("ACTB", letters[1:11], "ERCC-1", "__alignment_not_unique")

  #run function
  output <- moveGenesToRownames(testingCounts)

  #test
  expect_identical(rownames(output), e.rownames)
  expect_identical(output$HGN, NULL)
  expect_error(moveGenesToRownames(1:10))
  expect_error(moveGenesToRownames(matrix(1:10)))
  expect_error(moveGenesToRownames(data.frame(1:10)))
})

test_that("check convertCountsToMatrix", {

  #setup input
  input <- moveGenesToRownames(testingCounts)

  #run function
  output <- convertCountsToMatrix(input)

  #test
  expect_identical(class(output), "matrix")
  expect_error(convertCountsToMatrix(1:10))
  expect_error(convertCountsToMatrix(matrix(1:10)))
  expect_error(convertCountsToMatrix(testingCounts))
})

test_that("check removeHTSEQsuffix", {

  #setup input
  input <- moveGenesToRownames(testingCounts)

  #setup expected data
  e.colnames <- LETTERS[1:11]

  #run function
  output <- removeHTSEQsuffix(input)

  #test
  expect_identical(colnames(output), e.colnames)
  expect_error(removeHTSEQsuffix(1:10))
  expect_error(removeHTSEQsuffix(matrix(1:10)))
  expect_warning(removeHTSEQsuffix(data.frame(1:10, 1:10)))
  expect_warning(removeHTSEQsuffix(data.frame(a = 1:10, b = 1:10)))
})

test_that("check labelSingletsAndMultiplets", {

  #setup input
  input <- moveGenesToRownames(testingCounts)
  input <- removeHTSEQsuffix(input)

  #setup expected data
  e.colnames <- c(paste0("s.", LETTERS[1:5]), paste0("m.", LETTERS[6:11]))

  #run function
  output <- labelSingletsAndMultiplets(input, LETTERS[1:5])

  #test
  expect_identical(colnames(output), e.colnames)
  expect_error(labelSingletsAndMultiplets(1:10, LETTERS[1:5]))
  expect_error(labelSingletsAndMultiplets(matrix(1:10), LETTERS[1:5]))
  expect_error(labelSingletsAndMultiplets(testingCounts, LETTERS[1:5]))
  expect_warning(labelSingletsAndMultiplets(input, letters[1:5]))
  expect_error(labelSingletsAndMultiplets(testingCounts, TRUE))
})

test_that("check detectERCCreads", {

  #setup input
  #testingCounts only has 1 ercc read and thus generates a warning
  input <- data.frame(runif(100), row.names = c(1:8, paste0("ERCC-", 1:92)))

  #setup expected data
  expected <- c(rep(FALSE, 8), rep(TRUE, 92))

  #run function
  output <- detectERCCreads(input)

  #test
  expect_identical(output, expected)
  expect_error(detectERCCreads(1:10))
  expect_error(detectERCCreads(data.frame(1:10)))
})

test_that("check detectNonGenes", {

  #setup input
  input <- moveGenesToRownames(testingCounts)

  #setup expected data
  expected <- c(rep(FALSE, 13), TRUE)

  #run function
  output <- detectNonGenes(input)

  #test
  expect_identical(output, expected)
  expect_error(detectNonGenes(1:10))
  expect_error(detectNonGenes(data.frame(1:10)))
})

test_that("check detectLowQualityGenes", {

  #setup input
  input <- moveGenesToRownames(testingCounts)
  input <- input[!detectNonGenes(input), ]
  #testingCounts only has 1 ercc read and thus generates a warning
  input <- expect_warning(input[!detectERCCreads(input), ])

  #setup expected data
  expected <- c(rep(TRUE, 11), FALSE)
  names(expected) <- c("ACTB", letters[1:11])

  #run function
  output <- detectLowQualityGenes(input, 18)

  #test
  expect_identical(output, expected)
})

test_that("check detectLowQualityCells.totalCounts", {

  #setup input
  input <- moveGenesToRownames(testingCounts)
  input <- removeHTSEQsuffix(input)
  input <- input[!detectNonGenes(input), ]
  #testingCounts only has 1 ercc read and thus generates a warning
  input <- expect_warning(input[!detectERCCreads(input), ])

  #setup expected data
  expected <- c(rep(TRUE, 10), FALSE)
  names(expected) <- LETTERS[1:11]

  #run function
  output <- detectLowQualityCells.totalCounts(input, mincount = 30)

  #test
  expect_identical(output, expected)
})

test_that("check detectLowQualityCells.housekeeping", {

  #setup input
  input <- moveGenesToRownames(testingCounts)
  input <- removeHTSEQsuffix(input)
  input <- input[!detectNonGenes(input), ]
  #testingCounts only has 1 ercc read and thus generates a warning
  input <- expect_warning(input[!detectERCCreads(input), ])

  #setup expected data
  expected <- c(rep(TRUE, 4), FALSE, rep(TRUE, 6))
  names(expected) <- LETTERS[1:11]

  #run function
  output <- detectLowQualityCells.housekeeping(input, geneName = 'ACTB', quantileCut = 0.01)

  #test
  expect_identical(output, expected)
})

test_that("check detectLowQualityCells.ERCCfrac", {

  #setup input
  input <- moveGenesToRownames(testingCounts)
  input <- removeHTSEQsuffix(input)
  input <- input[!detectNonGenes(input), ]
  #testingCounts only has 1 ercc read and thus generates a warning
  input <- expect_warning(input[!detectERCCreads(input), ])

  #setup ercc
  set.seed(9834)
  ercc <- matrix(c(c(runif(10, 0, 10), 50), c(runif(10, 0, 10), 50)), nrow = 2, byrow = TRUE)

  #setup expected data
  expected <- c(rep(TRUE, 10), FALSE)
  names(expected) <- LETTERS[1:11]

  #run function
  output <- detectLowQualityCells.ERCCfrac(input, ercc, quantileCut = 0.99)

  #test
  expect_identical(output, expected)
})
