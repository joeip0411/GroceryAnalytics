from typing import Any, Mapping, Optional

import pandas as pd
from dagster import (
    AssetKey,
    AutoMaterializePolicy,
    OpExecutionContext,
    SourceAsset,
    asset,
)
from dagster_dbt import DagsterDbtTranslator, DbtCliResource, dbt_assets

from .config import (
    ObservationSkuInfoConfig,
    SpecialSkuConfig,
    SpecialSkuInfoConfig,
)
from .constants import dbt_manifest_path
from .Scraper import ScraperController


class CustomDagsterDbtTranslator(DagsterDbtTranslator):
    def get_auto_materialize_policy(
        self, dbt_resource_props: Mapping[str, Any]
    ) -> Optional[AutoMaterializePolicy]:
        return AutoMaterializePolicy.eager()

    def get_group_name(
        self, dbt_resource_props: Mapping[str, Any]
    ) -> Optional[str]:
        return "woolworths"
    
@dbt_assets(manifest=dbt_manifest_path,
            dagster_dbt_translator=CustomDagsterDbtTranslator())
def dbt_grocery_analytics_dbt_assets(context: OpExecutionContext, dbt: DbtCliResource):
    yield from dbt.cli(["build"], context=context).stream()


observation_sku = SourceAsset(key=AssetKey("grocery_basket_sku"), 
                              group_name = 'woolworths', 
                              io_manager_key='SnowflakeIOManagerGABronze')

special_url = SourceAsset(key=AssetKey("specials_url"), 
                          group_name='woolworths', 
                          io_manager_key='SnowflakeIOManagerGABronze')


@asset(group_name = 'woolworths', 
       io_manager_key='SnowflakeIOManagerGARaw',
       compute_kind="python")
def OBSERVATION_SKU_INFO_TEMP(config:ObservationSkuInfoConfig, grocery_basket_sku) -> pd.DataFrame:

    observation_sku = grocery_basket_sku['sku'].tolist()

    sc = ScraperController(max_workers = config.observation_sku_info_max_worker)
    observation_sku_info = sc.get_observation_sku_info(observation_sku)
    return observation_sku_info

@asset(group_name = 'woolworths', 
       io_manager_key='SnowflakeIOManagerGARaw',
       compute_kind="python")
def SPECIALS_SKU_TEMP(config:SpecialSkuConfig, specials_url) -> pd.DataFrame:

    special_url = specials_url[specials_url['selected'] == 1]['loc'].to_list()

    sc = ScraperController(max_workers = config.specials_sku_max_worker)
    special_skus = sc.get_all_sepcial_sku(special_url)
    return special_skus

@asset(group_name = 'woolworths',
       io_manager_key='SnowflakeIOManagerGARaw',
       compute_kind="python",
       auto_materialize_policy=AutoMaterializePolicy.eager())
def SPECIALS_SKU_INFO_TEMP(config:SpecialSkuInfoConfig, SPECIALS_SKU_TEMP) -> pd.DataFrame:
    specials_sku_list = SPECIALS_SKU_TEMP['sku'].to_list()

    sc = ScraperController(max_workers = config.special_sku_info_max_worker)
    special_sku_info = sc.get_sku_info_from_list(specials_sku_list)
    return special_sku_info