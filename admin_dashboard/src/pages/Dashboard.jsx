import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  Users, 
  UserCheck, 
  FileText, 
  Clock, 
  AlertTriangle, 
  CheckCircle, 
  IndianRupee, 
  UserX,
  ArrowRight,
  TrendingUp,
  FileWarning,
  Layers,
  ChevronRight
} from 'lucide-react';
import StatCard from '../components/StatCard';
import { adminApi } from '../services/adminApi';

export default function Dashboard() {
  const navigate = useNavigate();
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function loadData() {
      const data = await adminApi.getStats();
      setStats(data);
      setLoading(false);
    }
    loadData();
  }, []);

  if (loading || !stats) {
    return (
      <div className="p-8 flex items-center justify-center min-h-[60vh]">
        <div className="text-center space-y-3">
          <div className="animate-spin rounded-full h-10 w-10 border-b-2 border-emerald-600 mx-auto"></div>
          <p className="text-sm text-slate-500 font-medium">Aggregating MoTA Scholarship Statistics...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="p-8 space-y-8 max-w-7xl mx-auto">
      {/* Page Header */}
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div>
          <div className="flex items-center space-x-2">
            <h1 className="text-2xl font-bold text-slate-900 tracking-tight">MoTA Admin Dashboard</h1>
            <span className="bg-emerald-100 text-emerald-800 text-xs px-2.5 py-0.5 rounded-full font-semibold border border-emerald-300">
              Live Mock Stream
            </span>
          </div>
          <p className="text-sm text-slate-500 mt-1">
            Real-time multi-scheme verification, review routing, and saturation analytics
          </p>
        </div>

        <div className="flex items-center space-x-3">
          <button
            onClick={() => navigate('/admin/reviews')}
            className="inline-flex items-center px-4 py-2.5 rounded-lg bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-semibold shadow-sm transition"
          >
            <span>Review Queue</span>
            <ArrowRight className="w-3.5 h-3.5 ml-1.5" />
          </button>
          <button
            onClick={() => navigate('/admin/unreached')}
            className="inline-flex items-center px-4 py-2.5 rounded-lg bg-white border border-slate-300 hover:bg-slate-50 text-slate-700 text-xs font-semibold shadow-sm transition"
          >
            <span>Outreach Saturation</span>
            <Users className="w-3.5 h-3.5 ml-1.5 text-slate-500" />
          </button>
        </div>
      </div>

      {/* 8 Metric KPI Cards Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
        <StatCard
          title="Total Registered"
          value={stats.total_registered.toLocaleString()}
          icon={Users}
          color="blue"
          change="Unique Student IDs issued"
        />
        <StatCard
          title="Verified ST Students"
          value={stats.verified_st.toLocaleString()}
          icon={UserCheck}
          color="emerald"
          change="Level-1 e-KYC & Caste Verified"
        />
        <StatCard
          title="Applications Submitted"
          value={stats.applications_submitted.toLocaleString()}
          icon={FileText}
          color="indigo"
          change="Across 5 MoTA Schemes"
        />
        <StatCard
          title="Under Verification"
          value={stats.under_verification.toLocaleString()}
          icon={Clock}
          color="amber"
          change="Automated checks executing"
        />
        <StatCard
          title="Manual Review Required"
          value={stats.manual_review_required.toLocaleString()}
          icon={AlertTriangle}
          color="rose"
          change="Institutional / naming mismatches"
        />
        <StatCard
          title="Sanctioned"
          value={stats.sanctioned.toLocaleString()}
          icon={CheckCircle}
          color="emerald"
          change="Orders issued by authorities"
        />
        <StatCard
          title="Payments Disbursed"
          value={`₹${stats.payments_completed_crores} Cr`}
          icon={IndianRupee}
          color="purple"
          change="Direct Benefit Transfer via APB"
        />
        <StatCard
          title="Potentially Unreached"
          value={stats.potentially_unreached.toLocaleString()}
          icon={UserX}
          color="amber"
          change="Enrolled but missing benefits"
        />
      </div>

      {/* Middle Grid: Common Deficiencies & Quick System Overview */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Common Deficiencies Card */}
        <div className="bg-white rounded-xl border border-slate-200/90 p-6 shadow-sm flex flex-col justify-between">
          <div>
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center space-x-2">
                <FileWarning className="w-5 h-5 text-amber-500" />
                <h3 className="text-sm font-bold text-slate-800">Common Application Deficiencies</h3>
              </div>
              <span className="text-[11px] font-semibold text-slate-500 uppercase">Top Bottlenecks</span>
            </div>
            <p className="text-xs text-slate-500 mb-5">
              The automated verification orchestrator identifies expired or missing certificates and prompts students for revalidation.
            </p>

            <div className="space-y-4">
              {Object.entries(stats.common_deficiencies).map(([key, count]) => {
                const total = stats.common_deficiencies['Income Certificate'] + stats.common_deficiencies['Domicile Certificate'] + stats.common_deficiencies['Academic Marksheet'];
                const pct = Math.round((count / total) * 100);
                return (
                  <div key={key}>
                    <div className="flex justify-between text-xs font-semibold text-slate-700 mb-1">
                      <span>{key}</span>
                      <span className="text-slate-500">{count} cases ({pct}%)</span>
                    </div>
                    <div className="w-full bg-slate-100 rounded-full h-2 overflow-hidden">
                      <div
                        className="bg-amber-500 h-2 rounded-full transition-all duration-500"
                        style={{ width: `${pct}%` }}
                      ></div>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>

          <div className="mt-6 pt-4 border-t border-slate-100 flex items-center justify-between text-xs text-slate-500">
            <span>Automated revalidation active</span>
            <span className="text-emerald-600 font-semibold cursor-pointer" onClick={() => navigate('/admin/reviews')}>
              Resolve in queue →
            </span>
          </div>
        </div>

        {/* MoTA Core Principles & Layer Status */}
        <div className="bg-white rounded-xl border border-slate-200/90 p-6 shadow-sm flex flex-col justify-between">
          <div>
            <div className="flex items-center space-x-2 mb-4">
              <Layers className="w-5 h-5 text-emerald-600" />
              <h3 className="text-sm font-bold text-slate-800">JAGO Multi-Layer Architecture</h3>
            </div>

            <div className="space-y-3.5 text-xs text-slate-600">
              <div className="p-3 bg-slate-50 rounded-lg border border-slate-100">
                <span className="font-bold text-slate-800 block mb-0.5">Level 1: Identity & ST Verification</span>
                <span>Verified ONCE at student onboarding via UIDAI e-KYC and State e-District repository. Reused everywhere.</span>
              </div>

              <div className="p-3 bg-slate-50 rounded-lg border border-slate-100">
                <span className="font-bold text-slate-800 block mb-0.5">Level 2: Scheme Eligibility Engine</span>
                <span>Rule-based evaluation across all 5 MoTA schemes with automated one-scheme rule enforcement.</span>
              </div>

              <div className="p-3 bg-slate-50 rounded-lg border border-slate-100">
                <span className="font-bold text-slate-800 block mb-0.5">Level 3: Verification Orchestrator</span>
                <span>Discrepancy tolerance: Mismatches route to manual review rather than rejecting eligible tribal students.</span>
              </div>
            </div>
          </div>

          <div className="mt-6 pt-4 border-t border-slate-100">
            <button
              onClick={() => navigate('/admin/verification')}
              className="text-xs text-emerald-700 hover:text-emerald-800 font-semibold flex items-center"
            >
              <span>Inspect connected sources (DigiLocker, AISHE, APAAR)</span>
              <ChevronRight className="w-4 h-4 ml-1" />
            </button>
          </div>
        </div>

        {/* Quick Action Navigation Card */}
        <div className="bg-gradient-to-br from-slate-900 to-slate-800 text-white rounded-xl p-6 shadow-md flex flex-col justify-between">
          <div>
            <div className="flex items-center justify-between mb-4">
              <span className="text-xs font-bold uppercase tracking-wider text-emerald-400">Officer Operations</span>
              <span className="text-xs bg-slate-800 text-emerald-400 px-2.5 py-0.5 rounded border border-emerald-700/60 font-medium">MoTA Portal</span>
            </div>
            <h3 className="text-base font-bold text-white mb-2">Pending Manual Verification Cases</h3>
            <p className="text-xs text-slate-300 leading-relaxed mb-6">
              Case #VR-10245 (Rahul Kumar) is currently awaiting institutional alias review. Discrepancy between student profile and AISHE official record.
            </p>

            <div className="space-y-2">
              <button
                onClick={() => navigate('/admin/reviews/VR-10245')}
                className="w-full flex items-center justify-between px-4 py-2.5 rounded-lg bg-emerald-600 hover:bg-emerald-500 text-white text-xs font-semibold shadow transition"
              >
                <span>Inspect Case #VR-10245</span>
                <ChevronRight className="w-4 h-4" />
              </button>

              <button
                onClick={() => navigate('/admin/unreached')}
                className="w-full flex items-center justify-between px-4 py-2.5 rounded-lg bg-slate-800 hover:bg-slate-700 text-slate-200 text-xs font-medium border border-slate-700 transition"
              >
                <span>Launch Saturation Drive (300 Students)</span>
                <ChevronRight className="w-4 h-4 text-slate-400" />
              </button>
            </div>
          </div>

          <div className="mt-6 pt-4 border-t border-slate-800 text-[11px] text-slate-400 text-center">
            Demo data environment • All state updates persist locally
          </div>
        </div>
      </div>
    </div>
  );
}
