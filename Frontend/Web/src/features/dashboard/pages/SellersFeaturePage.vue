<script setup lang="ts">
import { computed, ref } from "vue";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import SectionCard from "../../../shared/components/SectionCard.vue";

const props = defineProps<{ marketplace: ReturnTypeUseMarketplace }>();
const search = ref("");
const kycFilter = ref("all");
const pageNumber = ref(1);
const pageSize = 20;

const filtered = computed(() => props.marketplace.state.value.sellers.filter((seller) => {
  if (kycFilter.value !== "all" && seller.kycStatus !== kycFilter.value) return false;
  if (!search.value.trim()) return true;
  const term = search.value.toLowerCase();
  return [seller.name, seller.businessName, seller.email].join(" ").toLowerCase().includes(term);
}));

const totalPages = computed(() => Math.max(1, Math.ceil(filtered.value.length / pageSize)));
const pageItems = computed(() => {
  const start = (pageNumber.value - 1) * pageSize;
  return filtered.value.slice(start, start + pageSize);
});

const setKyc = async (sellerId: string, status: "approved" | "rejected") => {
  if (status === "approved") await props.marketplace.approveKyc(sellerId);
  if (status === "rejected") await props.marketplace.rejectKyc(sellerId);
};
</script>

<template>
  <SectionCard title="Sellers Management">
    <div class="filters">
      <input v-model="search" placeholder="Search seller, company, email" />
      <select v-model="kycFilter"><option value="all">All KYC</option><option value="pending">Pending</option><option value="approved">Approved</option><option value="rejected">Rejected</option></select>
    </div>
    <table>
      <thead><tr><th>Seller Name</th><th>Company</th><th>Email</th><th>KYC</th><th>Gold/Silver/Diamond</th><th>Actions</th></tr></thead>
      <tbody>
        <tr v-for="seller in pageItems" :key="seller.id">
          <td>{{ seller.name }}</td><td>{{ seller.businessName }}</td><td>{{ seller.email }}</td><td>{{ seller.kycStatus }}</td>
          <td>{{ seller.goldPrice ?? '-' }} / {{ seller.silverPrice ?? '-' }} / {{ seller.diamondPrice ?? '-' }}</td>
          <td><button @click="setKyc(seller.id, 'approved')">Approve</button> <button class="danger" @click="setKyc(seller.id, 'rejected')">Reject</button></td>
        </tr>
      </tbody>
    </table>
    <div class="pager">Results: {{ (pageNumber - 1) * pageSize + 1 }} - {{ Math.min(pageNumber * pageSize, filtered.length) }} of {{ filtered.length }}
      <button :disabled="pageNumber <= 1" @click="pageNumber--">&lt;</button>
      <span>{{ pageNumber }} / {{ totalPages }}</span>
      <button :disabled="pageNumber >= totalPages" @click="pageNumber++">&gt;</button>
    </div>
  </SectionCard>
</template>

<style scoped>
.filters { display:grid; grid-template-columns:1fr 220px; gap:10px; margin-bottom:12px; }
.pager { margin-top: 10px; display:flex; gap:8px; align-items:center; justify-content:flex-end; }
</style>
