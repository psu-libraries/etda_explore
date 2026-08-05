function initializeDownloadModal() {
  document.addEventListener('show.bs.modal', function(e) {
    if (e.relatedTarget && e.relatedTarget.classList.contains('download-trigger')) {
      const filePath = e.relatedTarget.dataset.filePath;
      document.getElementById('modalDownloadLink').href = filePath;
    }
  });
}

initializeDownloadModal()