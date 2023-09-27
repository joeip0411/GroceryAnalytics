import concurrent.futures
import json
from datetime import datetime
from itertools import chain
from time import sleep
from typing import Dict, List

import pandas as pd
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait


# Factories
class WebDriverFactory:
    '''
    Factory class to create selenium web drivers

    Attributes:
        driver_path (str) : path of the Chrome driver executable
        user_agent (str): fake user agent to add to the web driver
        referrer (str) : fake referrer to add to the web driver
        servce (selenium.webdriver.chrome.service)
    '''
    def __init__(self):
        self.driver_path = "C:\\Users\\joete\\Desktop\\chromedriver.exe"
        self.user_agent = 'User-Agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36'
        self.referrer = 'Referrer=https://www.google.com/'
        
        self.options = webdriver.ChromeOptions()
        self.options.add_argument(self.user_agent)
        self.options.add_argument(self.referrer)

        self.service = Service(self.driver_path)

    def create_driver(self) -> webdriver.Chrome:
        '''
        Args:
            No arguments
        Returns:
            Selenium chrome driver with custom specifications
        '''
        return webdriver.Chrome(service = self.service, options = self.options)
    

# Domains
class Scraper:
    '''
    Domain class to handle scraing logic

    Attributes:
        sku_api_endpoint (str): endpoint to retrieve sku related information
    '''
    def __init__(self):
        self.sku_api_endpoint = 'https://www.woolworths.com.au/api/v3/ui/schemaorg/product/{sku}'
        self.sku_url_container = []

    def get_sku_info(self, sku:int, driver: webdriver.Chrome) -> dict:
        """
        Get SKU related information

        Args:
            sku (int): a particular sku
            driver (webdriver.Chrome): webdriver responsible for calling the API endpoint

        Returns:
            dict: SKU information in JSON
        """
        get_url = self.sku_api_endpoint.format(sku = sku)
        driver.get(get_url)

        wait = WebDriverWait(driver, 10)
        wait.until(EC.presence_of_element_located((By.XPATH, "/html/body/pre")))

        element = driver.find_element(By.XPATH, '/html/body/pre')
        response = json.loads(element.text)

        sleep(1)
        return response
    
    def get_sku_url_from_page(self, driver:webdriver.Chrome, url:str) -> pd.DataFrame:
        """
        Getting the product page url of a particular sku from a grid of products

        Args:
            driver (webdriver.Chrome): selenium chrome driver to handle the scraping task
            url (str): product grid page url

        Returns:
            pd.DataFrame: contains speicals category and SKU of products
        """
        
        driver.get(url)
        
        category = url.split('/')[-1].split('?')[0]

        ret = []

        wait = WebDriverWait(driver, 10)
        wait.until(EC.presence_of_element_located((By.CLASS_NAME, 'product-title-link.ng-star-inserted')))
        
        container_xpath = '//*[@id="search-content"]/div/shared-grid'
        product_class_name = 'product-title-link.ng-star-inserted'
        container = driver.find_element(By.XPATH, container_xpath)
        items = container.find_elements(By.CLASS_NAME, product_class_name)

        for i in range(len(items)):
            product_name = items[i].text
            href = items[i].get_attribute('href')
            if len(product_name) > 0:
                ret.append(href.split('/')[-2])

        df = pd.DataFrame({'category': category, 'sku': ret})

        sleep(1)

        return df
    
    def get_last_page_from_entry_point(self, driver:webdriver.Chrome, entry_url:str) -> int:
        """
        Get last page number of a specials category

        Args:
            driver (webdriver.Chrome): selenium chrome driver to handle the scraping task
            entry_url (str): the url of the first page of a special category

        Returns:
            int: the last page number of a special category
        """
        last_page_class = 'paging-pageNumber'

        driver.get(entry_url)

        wait = WebDriverWait(driver, 10)
        wait.until(EC.presence_of_element_located((By.CLASS_NAME, 'paging-pageNumber')))

        last_page_number = int(driver.find_elements(By.CLASS_NAME, last_page_class)[-1].text.split()[-1])
        sleep(1)

        return last_page_number
    
    def get_all_page_urls_from_entry_point(self, driver: webdriver.Chrome, entry_url:str) -> list:
        """
        Get all the page urls of a special category

        Args:
            driver (webdriver.Chrome): selenium chrome driver to handle the scraping task
            entry_url (str): the url of the first page of a special category

        Returns:
            list: all pages urls of a special category
        """

        last_page_number = self.get_last_page_from_entry_point(driver, entry_url)

        ret = [entry_url+'?pageNumber='+str(i) for i in range(1,last_page_number+1)]

        return ret
    
# Controllers
class ScraperController:
    """
    Controller class to coordinate different scraping logic

    Attributes:
        max_workers: maximum number of workers to handle the scraping task
        driver_factory: factory class object to create multiple selenium web drivers
        drivers_container: list to contain all the selenium web drivers created by the driver_factory
        scraper: domain class object to handle the scraping logic
    """
    def __init__(self, max_workers):
        self.max_workers = max_workers
        self.driver_factory = WebDriverFactory()
        # self.drivers_container = [self.driver_factory.create_driver() for i in range(self.max_workers)]
        self.drivers_container = [self.driver_factory.create_driver() for i in range((self.max_workers+1)*2)]
        self.scraper = Scraper()
        self.specials_retry_urls= []

    def get_sku_info_from_list(self, sku_list: list) -> pd.DataFrame:
        """
        Get SKU information from a list of SKU number, executed in a parallel fashion

        Args:
            sku_list (list): list of SKU ids

        Returns:
            pd.DataFrame: SKU information
        """

        # initialise more twice as much driver than executors,
        # alternately use the two batch of drivers for scrpaing to avoid stale element error
        with concurrent.futures.ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            scraping_tasks = []

            for i in range(len(sku_list)):
                if (i//self.max_workers)%2 == 0:
                    slot = i%self.max_workers+1
                else:
                    slot = (i%self.max_workers+1)+self.max_workers
                scraping_tasks.append(executor.submit(self.scraper.get_sku_info, sku_list[i], self.drivers_container[slot]))

            concurrent.futures.wait(scraping_tasks)

        results = [task.result() for task in scraping_tasks if task.exception() is None]
        
        df =  pd.DataFrame(results)
        df['extractionTime'] = datetime.utcnow()
        return df
    
    def get_all_page_url_from_specials_page(self, specialUrlList) -> list:
        """
        Get all page urls from specials category entry page

        Returns:
            list: all product grid page urls
        """

        with concurrent.futures.ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            scraping_tasks = []

            for i in range(len(specialUrlList)):
                if (i//self.max_workers)%2 == 0:
                    slot = i%self.max_workers+1
                else:
                    slot = (i%self.max_workers+1)+self.max_workers
                scraping_tasks.append(executor.submit(self.scraper.get_all_page_urls_from_entry_point, self.drivers_container[slot], specialUrlList[i]))
            
            concurrent.futures.wait(scraping_tasks)

        results = list(chain.from_iterable([task.result() for task in scraping_tasks if task.exception() is None]))
        
        return results
    
    def get_all_sepcial_sku(self, specialUrlList) -> pd.DataFrame:
        """
        Get all SKU informations that are on specials

        Returns:
            pd.DataFrame: all SKU informations that are on specials
        """

        product_grid_page_urls = self.get_all_page_url_from_specials_page(specialUrlList)

        with concurrent.futures.ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            scraping_tasks = []

            for i in range(len(product_grid_page_urls)):
                if (i//self.max_workers)%2 == 0:
                    slot = i%self.max_workers+1
                else:
                    slot = (i%self.max_workers+1)+self.max_workers
                scraping_tasks.append((executor.submit(self.scraper.get_sku_url_from_page, self.drivers_container[slot], product_grid_page_urls[i]), product_grid_page_urls[i])) # (task, product_grid_page_url[i])

            concurrent.futures.wait([i[0] for i in scraping_tasks])

        results = [task[0].result() for task in scraping_tasks if task[0].exception() is None]

        df = pd.concat(results)
        df['extractionTime'] = datetime.utcnow()

        return df
    
    def get_observation_sku_info(self, observationSku) -> pd.DataFrame:
        """
        Get information of SKU that I am interested

        Returns:
            pd.DataFrame: SKU information
        """

        ret = self.get_sku_info_from_list(observationSku)
        ret['extractionTime'] = datetime.utcnow()

        return ret
    
    def close_drivers(self):
        """
        Close all drivers initialised
        """
        for driver in self.drivers_container:
            driver.close()
