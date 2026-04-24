* Flow        = code + structure
* Deployment  = configuration wrapper for that flow
* Run         = a single execution created from a deployment

```
┌──────────────────────────────────────────────────────────┐
│ FLOW                                                     │
│  enveda-ms.batch-feature-calling-custom-pairs            │
│  (defines the DAG + parameter schema)                    │
└───────────────┬──────────────────────────────────────────┘
                │
        ┌───────┴────────────┐
        │                    │
┌───────▼────────┐   ┌───────▼────────┐
│ DEPLOYMENT     │   │ DEPLOYMENT     │
│ dev-ms_8_0     │   │ prod-ms_8_0    │
│ (dev config)   │   │ (prod config)  │
└───────┬────────┘   └────────────────┘
        │
   ┌────▼──────────────────────────────────────────┐
   │ FLOW RUN                                      │
   │ (one execution of the flow)                   │
   └───────────────────────────────────────────────┘
```
