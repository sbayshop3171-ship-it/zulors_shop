"use strict";

(function () {
    const placeholders = Array.from(document.querySelectorAll("[data-home-section][data-home-section-url]"));
    if (!placeholders.length) return;

    const maxConcurrentLoads = 2;
    const rootMargin = "650px 0px";
    const queue = [];
    let activeLoads = 0;

    function showRetry(container) {
        container.removeAttribute("aria-busy");
        container.classList.add("home-section-placeholder--failed");
        container.innerHTML = "";

        const button = document.createElement("button");
        button.type = "button";
        button.className = "btn btn--primary home-section-retry";
        button.textContent = container.dataset.retryLabel || "Try again";
        button.addEventListener("click", function () {
            container.classList.remove("home-section-placeholder--failed");
            container.setAttribute("aria-busy", "true");
            queueSection(container, true);
        }, { once: true });
        container.appendChild(button);
    }

    function finishLoad() {
        activeLoads = Math.max(0, activeLoads - 1);
        drainQueue();
    }

    function loadSection(container) {
        if (container.dataset.homeSectionState === "loaded" || container.dataset.homeSectionState === "loading") return;
        container.dataset.homeSectionState = "loading";
        activeLoads += 1;

        fetch(container.dataset.homeSectionUrl, {
            method: "GET",
            credentials: "same-origin",
            headers: {
                "Accept": "text/html",
                "X-Requested-With": "XMLHttpRequest",
                "X-Zulors-Home-Fragment": "1"
            }
        }).then(function (response) {
            if (!response.ok) throw new Error("Homepage section request failed");
            return response.text();
        }).then(function (html) {
            if (!html.trim()) {
                container.remove();
                return;
            }

            container.innerHTML = html;
            container.dataset.homeSectionState = "loaded";
            container.removeAttribute("aria-busy");
            container.classList.remove("home-section-placeholder");
            container.classList.add("home-section-loaded");
            document.dispatchEvent(new CustomEvent("zulors:home-fragment-loaded", { detail: container }));
        }).catch(function () {
            container.dataset.homeSectionState = "failed";
            showRetry(container);
        }).finally(finishLoad);
    }

    function drainQueue() {
        while (activeLoads < maxConcurrentLoads && queue.length) {
            const container = queue.shift();
            if (container.isConnected) loadSection(container);
        }
    }

    function queueSection(container, first = false) {
        if (!container.isConnected || container.dataset.homeSectionState === "loaded" || container.dataset.homeSectionState === "loading") return;
        if (!queue.includes(container)) {
            if (first) queue.unshift(container);
            else queue.push(container);
        }
        drainQueue();
    }

    if ("IntersectionObserver" in window) {
        const observer = new IntersectionObserver(function (entries) {
            entries.forEach(function (entry) {
                if (!entry.isIntersecting) return;
                observer.unobserve(entry.target);
                queueSection(entry.target);
            });
        }, { rootMargin: rootMargin, threshold: 0.01 });

        placeholders.forEach(function (container) { observer.observe(container); });
    } else {
        let scanQueued = false;
        function scanNearViewport() {
            if (scanQueued) return;
            scanQueued = true;
            window.requestAnimationFrame(function () {
                scanQueued = false;
                placeholders.forEach(function (container) {
                    if (container.dataset.homeSectionState === "loaded" || container.dataset.homeSectionState === "loading") return;
                    if (container.getBoundingClientRect().top < window.innerHeight + 650) queueSection(container);
                });
            });
        }
        window.addEventListener("scroll", scanNearViewport, { passive: true });
        window.addEventListener("resize", scanNearViewport, { passive: true });
        scanNearViewport();
    }
})();
