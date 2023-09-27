import os
from datetime import datetime

import pandas as pd
from dagster import IOManager


class LocalCsvIOManager(IOManager):
    path_prefix: str

    def _get_asset_path(self, context) -> str:
        return "/".join(context.asset_key.path)
    
    def _get_latest_file(self, context) -> str:
        assetName = self._get_asset_path(context)
        outputAssetDirectory = 'OutputData/' + assetName + '/'

        lastestFile = ''

        for filename in os.listdir(outputAssetDirectory):
            if filename > lastestFile:
                lastestFile = filename
        
        return lastestFile

    def _create_directory_if_not_exists(self, directory_path) -> None:
        if not os.path.exists(directory_path):
            os.makedirs(directory_path)

    def load_input(self, context):
        assetName = self._get_asset_path(context)
        directoryPath = 'OutputData/' + assetName+ '/'
        latestFile = self._get_latest_file(context)
        filePath = directoryPath + latestFile

        return pd.read_csv(filePath)
    
    def handle_output(self, context, obj):

        assetName = self._get_asset_path(context)
        directoryPath = 'OutputData/' + assetName+ '/'
        self._create_directory_if_not_exists(directoryPath)

        currentTimestamp = datetime.utcnow().strftime('%Y-%m-%d_%H-%M-%S')
        filePath = directoryPath + assetName + '_' +currentTimestamp + '.csv'
        obj.to_csv(filePath, index = False)

class LocalPartitionedCsvIOManager(IOManager):
    path_prefix: str

    def _get_asset_path(self, context) -> str:
        return "/".join(context.asset_key.path)
    
    def _get_file_path(self,context) -> str:
        partitionDateStr = context.asset_partition_key
        assetName = self._get_asset_path(context)
        outputDirectory  = 'OutputData/' + assetName+ '/'
        fileName = assetName + '_' +partitionDateStr + '.csv'
        filePath = outputDirectory + fileName
        return filePath
    
    def _create_directory_if_not_exists(self,directory_path):
        if not os.path.exists(directory_path):
            os.makedirs(directory_path)

    def load_input(self, context):
        filePath = self._get_file_path(context)
        return pd.read_csv(filePath)
    
    def handle_output(self, context, obj):
        assetName = self._get_asset_path(context)
        directoryPath = 'OutputData/' + assetName+ '/'
        self._create_directory_if_not_exists(directoryPath)

        filePath = self._get_file_path(context)
        obj.to_csv(filePath, index = False)


class LocalSourceCsvIOManager(IOManager):
    def _get_path(self, context) -> str:
        return "/".join(context.asset_key.path)

    def load_input(self, context):
        return pd.read_csv('SourceData/' + self._get_path(context) + '.csv')
    
    def handle_output(self, context, obj):
        pass
