# Benchling
"benchling_warehouse" is our postgresql db
"benchling_raw" delta lake files (clone of benchling_warehouse)
"benchling_views" easier queries (less normalized)

# use databricks query editor for autocompletion

# Enveda Toolkit (use internal pypi)
https://github.com/enveda/enveda-toolkit

# query data
client = get_client("prod")
client = get_client("dev")
client.query_df("""select * """)

# Formal writes to our datalake
client.to_datalake(
    df=some_df,

    # STORAGE
    path="test"
    storage_account="featurecallingus01",
    blob_container="results"

    # Databricks
    datbase="ms_6_0",
    table_name="test",
)

# Read/Write to storage
from enveda_toolkit import AzureBlobStorage
blob_store = AzureBlobStorage(storage_account='benchlingdevncus01')
blob_store.to_csv(df=my_df, container='views', path='test.csv')
blob_store.read_csv(container='views', path='test.csv')
