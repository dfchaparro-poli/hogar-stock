const state = {
  captures: [],
  current: 0,
  direction: 1,
};

const stage = document.querySelector('#carouselStage');
const dots = document.querySelector('#carouselDots');
const prevButton = document.querySelector('[data-prev]');
const nextButton = document.querySelector('[data-next]');
const downloadButton = document.querySelector('#downloadButton');
const downloadMeta = document.querySelector('#downloadMeta');
const currentYear = document.querySelector('#currentYear');
const downloadNavLink = document.querySelector('.nav a[href="#downloadButton"]');
const interactiveCursorSelector =
  '.brand, .brand *, .nav a, .primary-button:not(.disabled), .carousel-button:not(:disabled), .carousel-dots button';

async function loadJson(path, fallback) {
  try {
    const response = await fetch(path, { cache: 'no-store' });
    if (!response.ok) {
      return fallback;
    }
    return await response.json();
  } catch (_) {
    return fallback;
  }
}

function formatBytes(bytes) {
  if (!bytes || Number.isNaN(Number(bytes))) {
    return '';
  }
  const mb = Number(bytes) / 1024 / 1024;
  return `${mb.toFixed(1)} MB`;
}

async function setupDownload() {
  const data = await loadJson('./data/website-data.json', null);
  if (!data || !data.apkUrl) {
    downloadButton.textContent = 'APK no disponible';
    downloadButton.classList.add('disabled');
    downloadButton.removeAttribute('href');
    downloadButton.setAttribute('aria-disabled', 'true');
    downloadButton.style.cursor = 'not-allowed';
    downloadMeta.textContent = 'Publica un APK en release/ para habilitar la descarga.';
    return;
  }

  downloadButton.textContent = 'Descargar APK';
  downloadButton.href = data.apkUrl;
  downloadButton.download = data.apkName || '';
  downloadButton.classList.remove('disabled');
  downloadButton.removeAttribute('aria-disabled');
  downloadButton.style.cursor = 'pointer';

  const size = formatBytes(data.apkSize);
  downloadMeta.textContent = [data.apkName, size].filter(Boolean).join(' - ');
}

function setupCurrentYear() {
  if (currentYear) {
    currentYear.textContent = new Date().getFullYear();
  }
}

function focusDownloadButton() {
  downloadButton.classList.remove('download-focus');
  void downloadButton.offsetWidth;
  downloadButton.classList.add('download-focus');
  window.setTimeout(() => {
    downloadButton.classList.remove('download-focus');
  }, 1200);
}

function setupDownloadNavigation() {
  if (!downloadNavLink) {
    return;
  }

  downloadNavLink.addEventListener('click', (event) => {
    event.preventDefault();
    downloadButton.scrollIntoView({ behavior: 'smooth', block: 'start' });
    history.pushState(null, '', '#downloadButton');
    focusDownloadButton();
  });

  if (window.location.hash === '#downloadButton') {
    window.setTimeout(focusDownloadButton, 250);
  }
}

function setupInteractiveCursorFallback() {
  document.addEventListener('pointerover', (event) => {
    const target = event.target.closest(interactiveCursorSelector);
    if (target) {
      document.body.style.cursor = 'pointer';
    }
  });

  document.addEventListener('pointerout', (event) => {
    const target = event.target.closest(interactiveCursorSelector);
    const nextTarget = event.relatedTarget?.closest?.(interactiveCursorSelector);
    if (target && !nextTarget) {
      document.body.style.cursor = '';
    }
  });
}

function renderCarousel() {
  const captures = state.captures;
  prevButton.disabled = captures.length <= 1;
  nextButton.disabled = captures.length <= 1;
  dots.innerHTML = '';

  if (!captures.length) {
    stage.innerHTML =
      '<div class="empty-state">Agrega imagenes en <code>website/captures/</code> para mostrarlas aqui.</div>';
    return;
  }

  const capture = captures[state.current];
  const image = document.createElement('img');
  image.src = capture.src;
  image.alt = capture.alt || `Captura ${state.current + 1} de HogarStock`;
  image.loading = 'lazy';
  image.className = 'capture-phone-screen';

  const phoneBar = document.createElement('div');
  phoneBar.className = 'capture-phone-bar';
  phoneBar.setAttribute('aria-hidden', 'true');

  const phoneShell = document.createElement('div');
  phoneShell.className = `capture-phone-shell ${
    state.direction < 0 ? 'is-entering-prev' : 'is-entering-next'
  }`;
  phoneShell.append(phoneBar, image);

  stage.replaceChildren(phoneShell);

  captures.forEach((_, index) => {
    const dot = document.createElement('button');
    dot.type = 'button';
    dot.className = index === state.current ? 'active' : '';
    dot.setAttribute('aria-label', `Ver captura ${index + 1}`);
    dot.addEventListener('click', () => {
      state.direction = index < state.current ? -1 : 1;
      state.current = index;
      renderCarousel();
    });
    dots.appendChild(dot);
  });
}

function moveCarousel(direction) {
  if (state.captures.length <= 1) {
    return;
  }
  state.direction = direction;
  state.current =
    (state.current + direction + state.captures.length) % state.captures.length;
  renderCarousel();
}

async function setupCarousel() {
  const captures = await loadJson('./data/captures.json', []);
  state.captures = Array.isArray(captures) ? captures : [];
  state.current = 0;
  renderCarousel();

  prevButton.addEventListener('click', () => moveCarousel(-1));
  nextButton.addEventListener('click', () => moveCarousel(1));
  document.addEventListener('keydown', (event) => {
    if (event.key === 'ArrowLeft') {
      moveCarousel(-1);
    }
    if (event.key === 'ArrowRight') {
      moveCarousel(1);
    }
  });
}

setupCurrentYear();
setupInteractiveCursorFallback();
setupDownloadNavigation();
setupDownload();
setupCarousel();
