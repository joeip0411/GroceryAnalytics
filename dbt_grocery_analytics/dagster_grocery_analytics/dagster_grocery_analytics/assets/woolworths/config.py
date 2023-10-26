from dagster import Config


class ObservationSkuInfoConfig(Config):
    observation_sku_info_max_worker: int = 4

class SpecialSkuConfig(Config):
    specials_sku_max_worker: int = 4

class SpecialSkuInfoConfig(Config):
    special_sku_info_max_worker: int = 8
