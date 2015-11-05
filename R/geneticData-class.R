#' @include hetData-class.R
#' @include pedigree-class.R
checkGeneticData <- function(object)
{
	errors <- c()
	if(!is.numeric(object@founders))
	{
		errors <- c(errors, "Slot founders must be a numeric matrix")
	}
	#Error if all founders are NA (because the next condition after this involves max(,na.rm=T), which requires at least one non-NA val)
	else if(all(is.na(object@founders)))
	{
		errors <- c(errors, "Slot founders cannot contain only NA")
	}
	else if(max(abs(round(object@founders) - object@founders), na.rm=TRUE) > 0)
	{
		errors <- c(errors, "Slot founders must contain integer values")
	}
	
	if(!is.numeric(object@finals))
	{
		errors <- c(errors, "Slot finals must be a numeric matrix")
	}
	else if(all(is.na(object@finals)))
	{
		errors <- c(errors, "Slot finals cannot contain only NA")
	}
	else if(max(abs(round(object@finals) - object@finals), na.rm=TRUE) > 0)
	{
		errors <- c(errors, "Slot finals must contain integer values")
	}

	if(length(dim(object@finals)) != 2)
	{
		errors <- c(errors, "Slot finals must be a matrix")
	}
	if(length(dim(object@founders)) != 2)
	{
		errors <- c(errors, "Slot founders must be a matrix")
	}
	#Check that row and column names of finals and founders exist
	if(is.null(dimnames(object@founders)) || any(unlist(lapply(dimnames(object@founders), is.null))))
	{
		errors <- c(errors, "Slot founders must have row and column names")
	}
	if(is.null(dimnames(object@finals)) || any(unlist(lapply(dimnames(object@finals), is.null))))
	{
		errors <- c(errors, "Slot finals must have row and column names")
	}

	#Check for NA's in row and column names of finals and founders
	if(any(unlist(lapply(dimnames(object@founders), function(x) any(is.na(x))))))
	{
		errors <- c(errors, "Row and column names of slot founders cannot be NA")
	}
	if(any(unlist(lapply(dimnames(object@finals), function(x) any(is.na(x))))))
	{
		errors <- c(errors, "Row and column names of slot finals cannot be NA")
	}

	#Check that row and column names of finals and founders are unique
	if(any(unlist(lapply(dimnames(object@finals), function(x) length(x) != length(unique(x))))))
	{
		errors <- c(errors, "Row and column names of slot finals cannot contain duplicates")
	}
	if(any(unlist(lapply(dimnames(object@founders), function(x) length(x) != length(unique(x))))))
	{
		errors <- c(errors, "Row and column names of slot founders cannot contain duplicates")
	}

	nMarkers <- ncol(object@founders)
	markers <- colnames(object@finals)
	if(ncol(object@finals) != nMarkers || length(object@hetData) != nMarkers)
	{
		errors <- c(errors, "Slots finals, founders and hetData had different numbers of markers")
	}
	if(any(colnames(object@founders) != markers))
	{
		errors <- c(errors, "Slot finals must have the same colnames as slot founders")
	}
	if(any(names(object@hetData) != markers))
	{
		errors <- c(errors, "Slot hetData refers to different markers to slot finals")
	}
	
	#Check that each founder and final is in the pedigree
	if(!all(rownames(object@founders) %in% object@pedigree@lineNames))
	{
		errors <- c(errors, "Not all founder lines were named in the pedigree")
	}
	if(!all(rownames(object@finals) %in% object@pedigree@lineNames))
	{
		errors <- c(errors, "Not all final lines were named in the pedigree")
	}

	#If we have information on the founders in the pedigree, check that the founders ARE in fact those lines
	if(inherits(object@pedigree, "detailedPedigree"))
	{
		if(!all(rownames(object@founders) %in% object@pedigree@lineNames[object@pedigree@initial]) || nrow(object@founders) != length(object@pedigree@initial))
		{
			errors <- c(errors, "Founder lines did not match those specified in the pedigree")
		}
		if(!all(rownames(object@finals) %in% object@pedigree@lineNames[object@pedigree@observed]) || nrow(object@finals) != sum(object@pedigree@observed))
		{
			errors <- c(errors, "Final lines did not match those specified in the pedigree")
		}
	}
	#Don't continue to the C code if there are already problems - Especially if the founders / finals slots have the wrong types
	if(length(errors) > 0) return(errors)
	#This checks the relation between the het data, founder data and final data. It doesn't check that the het data is itself valid
	#It also checks that if any of the founders are NULL for a marker, ALL the founder alleles must be NULL, and all the finals alleles must be NULL too
	alleleDataErrors <- .Call("alleleDataErrors", object, 10, PACKAGE="mpMap2")
	if(length(alleleDataErrors) > 0)
	{
		errors <- c(errors, alleleDataErrors)
	}
	if(length(errors) > 0) return(errors)
	return(TRUE)
}
.geneticData <- setClass("geneticData", slots=list(finals = "matrix", founders = "matrix", hetData = "hetData", pedigree = "pedigree"), validity = checkGeneticData)