## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
# install from CRAN with install.packages('sfarrow')
# or install from devtools::install_github("wcjochem/sfarrow@main)
# load the library
library(sfarrow)
library(dplyr, warn.conflicts = FALSE)

## -----------------------------------------------------------------------------
# read an example dataset created from Python using geopandas
world <- st_read_parquet(system.file("extdata", "world.parquet", package = "sfarrow"))

class(world)
world
plot(sf::st_geometry(world))

## -----------------------------------------------------------------------------
# output the file to a new location
# note the warning about possible future changes in metadata.
st_write_parquet(world, dsn = file.path(tempdir(), "new_world.parquet"))

## -----------------------------------------------------------------------------
list.files(system.file("extdata", "ds", package = "sfarrow"), recursive = TRUE)

## -----------------------------------------------------------------------------
ds <- arrow::open_dataset(system.file("extdata", "ds", package="sfarrow"))

## -----------------------------------------------------------------------------
nc_ds <- read_sf_dataset(ds)

nc_ds

## ---- tidy=FALSE--------------------------------------------------------------
nc_d12 <- ds %>% 
            filter(split1 == 1, split2 == 2) %>%
            read_sf_dataset()

nc_d12
plot(sf::st_geometry(nc_d12), col="grey")

## -----------------------------------------------------------------------------
# this command will throw an error
# no geometry column selected for read_sf_dataset
# nc_sub <- ds %>% 
#             select('FIPS') %>% # subset of columns
#             read_sf_dataset()

# set find_geom
nc_sub <- ds %>%
            select('FIPS') %>% # subset of columns
            read_sf_dataset(find_geom = TRUE)

nc_sub

## ---- tidy=FALSE--------------------------------------------------------------
world %>%
  group_by(continent) %>%
  write_sf_dataset(file.path(tempdir(), "world_ds"), 
                   format = "parquet",
                   hive_style = FALSE)

## -----------------------------------------------------------------------------
list.files(file.path(tempdir(), "world_ds"))

## ---- tidy=FALSE--------------------------------------------------------------
arrow::open_dataset(file.path(tempdir(), "world_ds"), 
                    partitioning = "continent") %>%
  filter(continent == "Africa") %>%
  read_sf_dataset()

