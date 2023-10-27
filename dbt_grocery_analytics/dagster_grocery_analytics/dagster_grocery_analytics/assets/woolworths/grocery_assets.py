from typing import Any, Mapping, Optional

import pandas as pd
from dagster import (
    AssetKey,
    AutoMaterializePolicy,
    AutoMaterializeRule,
    OpExecutionContext,
    SourceAsset,
    asset,
)
from dagster_dbt import DagsterDbtTranslator, DbtCliResource, dbt_assets

from dagster_grocery_analytics.assets.woolworths.config import (
    ObservationSkuInfoConfig,
    SpecialSkuConfig,
    SpecialSkuInfoConfig,
)
from dagster_grocery_analytics.assets.woolworths.constants import dbt_manifest_path
from dagster_grocery_analytics.assets.woolworths.Scraper import ScraperController

wait_for_all_parents_policy = AutoMaterializePolicy.eager()\
    .with_rules(AutoMaterializeRule.skip_on_not_all_parents_updated())

class CustomDagsterDbtTranslator(DagsterDbtTranslator):
    """Class to modify default behaviour of dagster-dbt
    """
    def get_auto_materialize_policy(self, 
                                    dbt_resource_props: Mapping[str, Any],
                                ) -> Optional[AutoMaterializePolicy]:
        """Set default auto materialisation policy for dbt assets
        """
        return AutoMaterializePolicy.eager()

    # def get_group_name(self, 
    #                    dbt_resource_props: Mapping[str, Any],
    #                 ) -> Optional[str]:
    #     """Set default asset group for dbt asset
    #     """
    #     return "woolworths"
    
@dbt_assets(manifest=dbt_manifest_path,
            dagster_dbt_translator=CustomDagsterDbtTranslator())
def dbt_grocery_analytics_dbt_assets(context: OpExecutionContext, dbt: DbtCliResource):
    """dbt assets in this dagster project
    """
    yield from dbt.cli(["build"], context=context).stream()


observation_sku = SourceAsset(key=AssetKey("grocery_basket_sku"), 
                              io_manager_key='SnowflakeIOManagerGABronze')

special_url = SourceAsset(key=AssetKey("specials_url"), 
                          io_manager_key='SnowflakeIOManagerGABronze')


@asset(io_manager_key='SnowflakeIOManagerGARaw',
       compute_kind="python")
def OBSERVATION_SKU_INFO_TEMP(config:ObservationSkuInfoConfig, #noqa N802
                              grocery_basket_sku) -> pd.DataFrame:
    """Product related data for grocery basket products
    """

    observation_sku = grocery_basket_sku['sku'].tolist()

    sc = ScraperController(max_workers = config.observation_sku_info_max_worker)
    observation_sku_info = sc.get_observation_sku_info(observation_sku)
    return observation_sku_info

@asset(io_manager_key='SnowflakeIOManagerGARaw',
       compute_kind="python")
def SPECIALS_SKU_TEMP(config:SpecialSkuConfig, #noqa N802
                      specials_url) -> pd.DataFrame: 
    """SKU for product which is on specials
    """

    special_url = specials_url[specials_url['selected'] == 1]['loc'].to_list()

    sc = ScraperController(max_workers = config.specials_sku_max_worker)
    special_skus = sc.get_all_sepcial_sku(special_url)
    return special_skus

@asset(io_manager_key='SnowflakeIOManagerGARaw',
       compute_kind="python",
       auto_materialize_policy=AutoMaterializePolicy.eager())
def SPECIALS_SKU_INFO_TEMP(config:SpecialSkuInfoConfig, #noqa N802
                           SPECIALS_SKU_TEMP) -> pd.DataFrame: #noqa N802
    """Product related data for product which is on specials
    """
    specials_sku_list = SPECIALS_SKU_TEMP['sku'].to_list()

    sc = ScraperController(max_workers = config.special_sku_info_max_worker)
    special_sku_info = sc.get_sku_info_from_list(specials_sku_list)
    return special_sku_info