// src/routes/dataset.js
// Dataset delivery endpoints — per SYSTEM_ARCHITECTURE.md SS-04
// App downloads dataset bundle once, then works fully offline.

const express = require('express');
const router = express.Router();
const supabase = require('../lib/supabase');
const { requireApiKey } = require('../middleware/auth');

// GET /api/v1/dataset/regions
// Returns all active dataset regions visible to the app.
router.get('/regions', requireApiKey, async (req, res) => {
  const { data, error } = await supabase
    .from('dataset_regions')
    .select('region_id, display_name, version, valid_until, bundle_size_bytes, checksum_sha256, is_active')
    .eq('is_active', true)
    .order('region_id');

  if (error) {
    console.error('[dataset] regions error:', error.message);
    return res.status(500).json({ error: 'fetch_failed' });
  }

  res.json({ regions: data });
});

// GET /api/v1/dataset/regions/:regionId
// Returns metadata + signed download URL for a specific region bundle.
// App uses this to check if a newer version is available and to download it.
router.get('/regions/:regionId', requireApiKey, async (req, res) => {
  const { regionId } = req.params;

  const { data, error } = await supabase
    .from('dataset_regions')
    .select('*')
    .eq('region_id', regionId)
    .eq('is_active', true)
    .single();

  if (error || !data) {
    return res.status(404).json({ error: 'region_not_found' });
  }

  // Generate a signed download URL from Supabase Storage (valid 1 hour)
  let downloadUrl = null;
  if (data.storage_path) {
    const { data: signedData, error: signError } = await supabase
      .storage
      .from('dataset-bundles')
      .createSignedUrl(data.storage_path, 3600);

    if (!signError && signedData) {
      downloadUrl = signedData.signedUrl;
    }
  }

  res.json({
    region_id:        data.region_id,
    display_name:     data.display_name,
    version:          data.version,
    valid_until:      data.valid_until,
    bundle_size_bytes: data.bundle_size_bytes,
    checksum_sha256:  data.checksum_sha256,
    policy_version:   data.policy_version,
    legal_source_baseline_date: data.legal_source_baseline_date,
    download_url:     downloadUrl,
    download_url_expires_in_seconds: downloadUrl ? 3600 : null
  });
});

// GET /api/v1/dataset/regions/:regionId/check
// Lightweight version check — app polls this to know if a newer bundle is available.
// Returns only {region_id, current_version, client_version_is_current}.
router.get('/regions/:regionId/check', requireApiKey, async (req, res) => {
  const { regionId } = req.params;
  const clientVersion = req.query.client_version;

  const { data, error } = await supabase
    .from('dataset_regions')
    .select('region_id, version, valid_until, is_active')
    .eq('region_id', regionId)
    .single();

  if (error || !data) {
    return res.status(404).json({ error: 'region_not_found' });
  }

  res.json({
    region_id:               data.region_id,
    server_version:          data.version,
    is_active:               data.is_active,
    valid_until:             data.valid_until,
    client_version_is_current: clientVersion ? (clientVersion === data.version) : null
  });
});

module.exports = router;
